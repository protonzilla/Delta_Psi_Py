# -*- coding: utf-8 -*-

#*******************************************************************************
#*******************************************************************************
#                       Importing required libraries                           *
#*******************************************************************************
#*******************************************************************************


# -*- coding: utf-8 -*-
import sys
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import odeint
from scipy.integrate import ode
from matplotlib.ticker import FormatStrFormatter
import matplotlib as mpl
import importlib as im
from matplotlib import cm
import copy
import pandas as pd
from scipy import integrate
from scipy import signal
from IPython.core.display import display, HTML


#*******************************************************************************
#*******************************************************************************
#                   Code related to naming states and constants                *
#*******************************************************************************
#*******************************************************************************

# labels for the results of odeint(f, ... )
species_labels = [
    'QA', # 0
    'QAm', #1 
    'PQ', #2
    'PQH2', #3
    'Hin', #4
    'pHlumen', #5
    'Dy', #6
    'pmf', #7
    'DeltaGatp', #8
    'Klumen', #9
    'Kstroma', #10
    'ATP_made', #11
    'PC_ox', #12
    'PC_red', #13
    'P700_ox', #14
    'P700_red', #15
    'Z_array', #16
    'V_array', #17
    'NPQ_array', #18
    'singletO2_array', #19
    'Phi2_array', #20
    'LEF_array', #21
    'Fd_ox',
    'Fd_red',
    'ATP_pool',
    'ADP_pool',
    'NADPH_pool',
    'NADP_pool'
    ]


#Location for the PDF files describing the parameters
#This can be over-written during the actual run
PDF_file_location='/Users/davidkramer/Dropbox/Data/DF_ECS/Params.png/' 

#In several places the code sometimes returns Nans resulting from divisions by 
#zero. This code supresses the warnings to de-clutter the display.

import warnings
warnings.filterwarnings("ignore")




#*******************************************************************************
#*******************************************************************************
#                   Code related to generating light curves                    *
#*******************************************************************************
#*******************************************************************************

#the following two parameters are used to generate the time and light curves
#for the simulations. It is needed to prevent very abrupt changes in conditons
#that would make the simulaitons too stiff for odeint. The default values are 
#typically OK, but can be adjusted if odeint produces garbage.

max_light_change=1
points_per_segment=100


#the following code sets up a light regime based on sin waves. The wave can 
#be either a sin or a square wave.

#total_duration=the duraction in time units of the complete wave form
#time_units are the time units, either  'seconds', 'minutes' or 'hours'.
#max_PAR is the maximum light intensity
#wave_form indicates if the wave is either a 'sin' or a 'square' wave
#light_frequency is the frequencgy in Hz for the waveform
# e.g. light_frequency=1/(60*60) will result in a one-hour duration wave

def generate_sin_based_light_sequence (total_duration, time_units, max_PAR, 
                                    wave_form, light_frequency, 
                                    point_frequency):
                                    
    #number_segments is the number of segments to split the sequence. The time_slice 
    #will be adjusted for each segment to keep the changes under a certain value.  
    #total_duration, time_units, time_slice, max_PAR, PAR_offset, clipping, light_frequency

    if time_units=='seconds':
        time_div=1
    elif time_units=='minutes':
        time_div=60
    elif time_units=='hours':
        time_div=60*60

    if wave_form=='sin':
        clipping=[0,2]
        PAR_offset=1000

    elif wave_form=='square':
        clipping=[-0.1,0.1] #the numbers used here define the sharpness of the 'square wave'
        PAR_offset=0

    total_duration_in_seconds=total_duration*time_div
    test_number_points=total_duration_in_seconds*point_frequency
    test_times_array=np.linspace(0, total_duration_in_seconds, test_number_points, dtype=float)

    #make the full waveform at high resolution
    test_sin_light_list=[]
    #print('length of test array is: ' + str(len(test_times_array)))
    for i in test_times_array:
        sinLt=np.sin(i*2*np.pi*light_frequency-(np.pi/2))
        sinLt=sinLt+(PAR_offset/max_PAR) #add the offset value, as a fraction of the max_PAR
        if sinLt<clipping[0]: #cannot have negative light, so when the curve goes below, assume it is night
            sinLt=(PAR_offset/max_PAR)-1
        if sinLt>clipping[1]: #gives sharp, square-wave-like limit #cannot have light, so when the
                            #curve goes below, assume it is night
            sinLt=1+(PAR_offset/max_PAR)
        test_sin_light_list.append(sinLt)
        
    test_sin_light_list=np.array(test_sin_light_list)
    test_sin_light_list=test_sin_light_list/np.max(test_sin_light_list)
    test_sin_light_list=test_sin_light_list*max_PAR
    #print(len(test_sin_light_list))
    
    return([test_times_array, test_sin_light_list])


#number_segments is the number of segments to split the sequence. The time_slice will be adjusted for each segment
#to keep the changes under a certain value.   

def generate_square_wave_based_light_sequence (baseline_duration, baseline_intensity, pulse_duration, pulse_intensity, 
                                        recovery_duration, recovery_intensity, rise_time, time_units, point_frequency,
                                        repeat_cycles):
    pulse_times=[]
    pulse_light=[]

    if time_units=='seconds':
        time_div=1
    elif time_units=='minutes':
        time_div=60
    elif time_units=='hours':
        time_div=60*60

    baseline_duration=baseline_duration*time_div
    baseline_points=baseline_duration*point_frequency
    baseline_time=np.linspace(0, baseline_duration, baseline_points)
    baseline_intensity_array= np.linspace(baseline_intensity, baseline_intensity,baseline_points)
    pulse_times=np.append(pulse_times, baseline_time)
    pulse_light=np.append(pulse_light, baseline_intensity_array)

    riser_duration=rise_time*time_div
    riser_points=riser_duration*point_frequency
    riser_start_time = (baseline_points+1) / point_frequency
    riser_end_time = riser_start_time + riser_duration
    riser_time=np.linspace(riser_start_time, riser_end_time, riser_points)
    riser_light=np.linspace(baseline_intensity, pulse_intensity, riser_points)
    
    pulse_times=np.append(pulse_times, riser_time)
    pulse_light=np.append(pulse_light, riser_light)
    pulse_duration=pulse_duration*time_div
    pulse_points=pulse_duration*point_frequency
    pulse_start_time = (baseline_points + riser_points +1)/point_frequency
    pulse_end_time = pulse_start_time + pulse_duration
    pulse_time=np.linspace(pulse_start_time, pulse_end_time, pulse_points)
    pulse_light_array=np.linspace(pulse_intensity, pulse_intensity, pulse_points)
    pulse_times=np.append(pulse_times, pulse_time)
    pulse_light=np.append(pulse_light, pulse_light_array)
    
    falling_duration=rise_time*time_div
    falling_points=riser_duration*point_frequency
    falling_start_time = (baseline_points + riser_points + pulse_points + 1) / point_frequency
    falling_end_time = falling_start_time + falling_duration
    falling_time=np.linspace(falling_start_time, falling_end_time, falling_points)
    falling_light=np.linspace(pulse_intensity, recovery_intensity, falling_points)
    
    pulse_times=np.append(pulse_times, falling_time)
    pulse_light=np.append(pulse_light, falling_light)
    
    recovery_duration=recovery_duration*time_div
    recovery_points=recovery_duration*point_frequency
    recovery_start_time = (baseline_points + riser_points + pulse_points + falling_points + 1) / point_frequency
    recovery_end_time = recovery_start_time + recovery_duration
    recovery_time=np.linspace(recovery_start_time, recovery_end_time, recovery_points)
    recovery_light=np.linspace(recovery_intensity, recovery_intensity, recovery_points)

    pulse_times=np.append(pulse_times, recovery_time)
    pulse_light=np.append(pulse_light, recovery_light)
    pulse_times_seq=[]
    pulse_light_seq=[]
    
    for index in range(0,repeat_cycles):
        pulse_times_seq=np.append(pulse_times_seq, pulse_times + index * pulse_times[-1])
        pulse_light_seq=np.append(pulse_light_seq, pulse_light)
    return([pulse_times_seq, pulse_light_seq])




#generate a light sequence that contains fluctuations
                    
def fluctuating(total_time, frequency_of_fluctuations, rise_time, max_light, envelope):
    
    #random fluctuations
    #general terms for the pulsed wave:
    duration_of_fluctuation=1/frequency_of_fluctuations
    number_of_cycles=int(total_time/ duration_of_fluctuation)
    
    #set up the basic structure of the square pulse 
    baseline_duration=0.25*duration_of_fluctuation #in seconds
    pulse_duration=0.5*duration_of_fluctuation #100 seconds pulse
    recovery_duration = 0.25*duration_of_fluctuation #100 seconds recovery
    rise_time=1 #1 s for the light to rise
    time_units='seconds' 
    point_frequency=100 #start with a frequency of 1000 points per subtrace
    repeat_cycles=1 #do this once
    rx=np.array([])
    ry=np.array([])
    for i in range(0,number_of_cycles):
        if (envelope == 'sin'):
            sinLt=max_light*(np.sin(i*2*np.pi/number_of_cycles-(np.pi/2))+1)
        else:
            sinLt=max_light
            
        inten=np.random.uniform(0, sinLt, size=3)
        pulse_intensity=inten[0] #pulse is 300 uE m-2 s-1 units
        baseline_intensity=inten[1] #dark baseline
        recovery_intensity=inten[2] #recovery is dark
    
    
        xy=generate_square_wave_based_light_sequence(baseline_duration, baseline_intensity,
                            pulse_duration, pulse_intensity, recovery_duration, recovery_intensity, 
                            rise_time, time_units, point_frequency, repeat_cycles)
                            
        if len(rx)>0:
            rx=np.append(rx, rx[-1]+np.array(xy[0]))
        else:
            rx=np.append(rx, np.array(xy[0]))
        ry=np.append(ry, np.array(xy[1]))
    return [rx,ry]


                    
def generate_square_wave_based_light_sequence (baseline_duration, baseline_intensity, pulse_duration, pulse_intensity, 
                                        recovery_duration, recovery_intensity, rise_time, time_units, point_frequency,
                                        repeat_cycles):
    pulse_times=[] #array that contains the complete time sequence
    pulse_light=[] #array to contain the complete intensity sequence 
    if time_units=='seconds':
        time_div=1
    elif time_units=='minutes':
        time_div=60
    elif time_units=='hours':
        time_div=60*60

    baseline_duration=baseline_duration*time_div
    baseline_points=baseline_duration*point_frequency #calculate the number of points in the baseline
    baseline_time=np.linspace(0, baseline_duration, baseline_points) #generate the baseline array, starting at zero
    baseline_intensity_array= np.linspace(baseline_intensity, baseline_intensity,baseline_points) #fill baseline array with baseline light intensity

    pulse_times=np.append(pulse_times, baseline_time) 
    pulse_light=np.append(pulse_light, baseline_intensity_array)

    riser_duration=rise_time*time_div
    riser_points=riser_duration*point_frequency
    riser_start_time = (baseline_points+1) / point_frequency
    
    riser_end_time = riser_start_time + riser_duration
    riser_time=np.linspace(riser_start_time, riser_end_time, riser_points)
    riser_light=np.linspace(baseline_intensity, pulse_intensity, riser_points)
    #print('rst= ' + str(riser_start_time))
    #print('ret= ' + str(riser_end_time))
    
    pulse_times=np.append(pulse_times, riser_time)
    pulse_light=np.append(pulse_light, riser_light)
    
    pulse_duration=pulse_duration*time_div
    pulse_points=pulse_duration*point_frequency
    #pulse_start_time = (baseline_points + riser_points +1)/point_frequency
    
    pulse_start_time = pulse_times[-1] + 1/point_frequency
    
    pulse_end_time = pulse_start_time + pulse_duration
    
    #print('pst= ' + str(pulse_start_time))
    #print('pet= ' + str(pulse_end_time))


    pulse_time=np.linspace(pulse_start_time, pulse_end_time, pulse_points)
    pulse_light_array=np.linspace(pulse_intensity, pulse_intensity, pulse_points)
    pulse_times=np.append(pulse_times, pulse_time)
    pulse_light=np.append(pulse_light, pulse_light_array)
    
    falling_duration=rise_time*time_div
    falling_points=riser_duration*point_frequency
    
    #falling_start_time = (baseline_points + riser_points + pulse_points + 1) / point_frequency
    falling_start_time = pulse_times[-1] + 1/point_frequency

    falling_end_time = falling_start_time + falling_duration
    
    #print('fst= ' + str(falling_start_time))
    #print('fet= ' + str(falling_end_time))


    falling_time=np.linspace(falling_start_time, falling_end_time, falling_points)
    falling_light=np.linspace(pulse_intensity, recovery_intensity, falling_points)
    
    pulse_times=np.append(pulse_times, falling_time)
    pulse_light=np.append(pulse_light, falling_light)
    
    recovery_duration=recovery_duration*time_div
    recovery_points=recovery_duration*point_frequency
    recovery_start_time = pulse_times[-1] + 1/point_frequency
    recovery_end_time = recovery_start_time + recovery_duration
    

    recovery_time=np.linspace(recovery_start_time, recovery_end_time, recovery_points)
    recovery_light=np.linspace(recovery_intensity, recovery_intensity, recovery_points)

    pulse_times=np.append(pulse_times, recovery_time)
    pulse_light=np.append(pulse_light, recovery_light)
    pulse_times_seq=[]
    pulse_light_seq=[]
    
    for index in range(0,repeat_cycles):
        pulse_times_seq=np.append(pulse_times_seq, pulse_times + index * pulse_times[-1])
        pulse_light_seq=np.append(pulse_light_seq, pulse_light)
    return([pulse_times_seq, pulse_light_seq])
    


#smooths a trace using the simple boxcar algorithm. 'box_pts' is the box size and y is the trace. It assumes equally spaced data\n",
def smooth(yvals, box_pts):
    box = np.ones(box_pts)/box_pts
    y_smooth = np.convolve(yvals, box, mode='full')
    return y_smooth
    
def flat_light(day_length_h, PAR, points_per_second):
    day_length_s=day_length_h*60*60
    time_axis_s=np.linspace(0,day_length_s, day_length_s*points_per_second)
    flat_envelope=np.linspace(PAR,PAR, day_length_s*points_per_second)
    return(time_axis_s, flat_envelope)

def sin_light(day_length, max_PAR, points_per_second): 
    
    day_length_s=day_length*60*60
    time_axis_s = np.linspace(0, day_length_s, day_length_s*points_per_second, endpoint=False)
    time_axis_h=time_axis_s/(60*60)
    
    #generate the envelope trace
    envelope=signal.cosine(day_length_s*points_per_second)*max_PAR
    return([time_axis_s, envelope])


def generate_light_profile(input_envelope, fluctuations): 
    time_axis_s=input_envelope[0]
    day_length_s=time_axis_s[-1]
    points_per_second=len(time_axis_s)/day_length_s
    time_axis_h=time_axis_s/(60*60)
    envelope=input_envelope[1]
    
    light_fluct=np.array([])
    light_array=np.array([])
    if fluctuations['type']=='square':

        time_index=0
        if fluctuations['distribution']=='random':
            #print('random')
            if fluctuations['begin'] == 'beginning':
                start_point=0
            else:
                start_point=int(float(fluctuations['begin'])*3600)*points_per_second  #convert to seconds

            if fluctuations['end'] == 'end':
                end_point=int(len(time_axis_s))
            else:
                end_point=int(float(fluctuations['end'])*3600)*points_per_second #convert to seconds

            while time_index<len(time_axis_s): #day_length_s:
                duration_of_fluctuation=np.random.randint(fluctuations['tao'])
                if (time_index>start_point-1) and (time_index<end_point+1):
                    fluctuation_amplitude=np.random.uniform(float(fluctuations['amplitude'][0]), float(fluctuations['amplitude'][1]))
                    light_value=envelope[len(light_fluct)]*(1-fluctuation_amplitude)
                    light_fluct=np.append(light_fluct, np.linspace(fluctuation_amplitude, fluctuation_amplitude, (duration_of_fluctuation*points_per_second)))
                    light_array=np.append(light_array, np.linspace(light_value, light_value, (duration_of_fluctuation*points_per_second)))

                else:
                    light_fluct=np.append(light_fluct, np.linspace(0, 0, (duration_of_fluctuation*points_per_second)))
                    light_array=np.append(light_array, envelope[time_index:time_index+int(duration_of_fluctuation*points_per_second)])

                    #light_value = envelope[len(light_fluct)]


                time_index=time_index+int(duration_of_fluctuation*points_per_second)
            light_array_smoothed=smooth(light_array, int(fluctuations['smooth_points']))
            out_put_light_array=light_array_smoothed[0:len(time_axis_s)]
    else:
        out_put_light_array=envelope
        
    return([time_axis_s, out_put_light_array])

def multiply_light_pattern(pattern, times_to_repeat):
    wave_x=np.array([])
    wave_y=np.array([])
    time_offset=0
    for index in range(0,times_to_repeat):
        wave_x=np.append(wave_x, pattern[0]+time_offset)
        wave_y=np.append(wave_y, pattern[1])
        time_offset=wave_x[-1]
    return [wave_x, wave_y]
    
def make_waves():
    # Generate a library of light patterns to use in the simulations.
    light_pattern={}
    
    #a single turnover flash  
    
    baseline_duration=1 # 10 ms dark timein seconds
    baseline_intensity=0 #dark baseline
    pulse_duration=0.001 # 10 ms pulse of bright light 
    pulse_intensity=3000 #pulse is 1000 units
    recovery_duration = 10 #10 s recovery in dark
    recovery_intensity=0 #recovery is dark
    rise_time=.001 #100 ms for the light to rise
    time_units='seconds' 
    point_frequency=1000 #start with a frequency of 1000 points per subtrace
    repeat_cycles=1 #do this once
    wave=generate_square_wave_based_light_sequence (baseline_duration, baseline_intensity,
                        pulse_duration, pulse_intensity, recovery_duration, recovery_intensity, 
                        rise_time, time_units, point_frequency, repeat_cycles)
    light_pattern['single_turnover_flash']=wave
    
    
    #a single, 5-min square wave with peak intensity of 300 uE
    baseline_duration=150 #in seconds
    baseline_intensity=0 #dark baseline
    pulse_duration=300 #300 seconds pulse
    pulse_intensity=300 #pulse is 1000 units
    recovery_duration = 600 #100 seconds recovery
    recovery_intensity=0 #recovery is dark
    rise_time=1 #100 ms for the light to rise
    time_units='seconds' 
    point_frequency=100 #start with a frequency of 1000 points per subtrace
    repeat_cycles=1 #do this once
    wave=generate_square_wave_based_light_sequence (baseline_duration, baseline_intensity,
                        pulse_duration, pulse_intensity, recovery_duration, recovery_intensity, 
                        rise_time, time_units, point_frequency, repeat_cycles)
    
    light_pattern['single_square_5_min_300_max']=wave

    #a single, 5-min square wave with peak intensity of 600 uE
    baseline_duration=150 #in seconds
    baseline_intensity=0 #dark baseline
    pulse_duration=300 #300 seconds pulse
    pulse_intensity=400 #pulse is 1000 units
    recovery_duration = 500 #100 seconds recovery
    recovery_intensity=0 #recovery is dark
    rise_time=1 #100 ms for the light to rise
    time_units='seconds' 
    point_frequency=100 #start with a frequency of 1000 points per subtrace
    repeat_cycles=1 #do this once
    wave=generate_square_wave_based_light_sequence (baseline_duration, baseline_intensity,
                        pulse_duration, pulse_intensity, recovery_duration, recovery_intensity, 
                        rise_time, time_units, point_frequency, repeat_cycles)
    light_pattern['single_square_5_min_600_max']=wave
    
    #make a single one-hour sin wave with max PAR of 300 uE
    total_duration=60*60 #duration is in seconds, so we do 3600 
    light_frequency=1/(60*60) #make the frequency the same as the duration to get one cycle
    points_per_second=10
    max_PAR=300
    wave=generate_sin_wave (total_duration, max_PAR, light_frequency, points_per_second)
    light_pattern['single_sin_wave_1_hr_300_max']=wave
            
    #make a single one-hour sin wave with max PAR of 300 uE
    total_duration=60*60 #duration is in seconds, so we do 3600 
    light_frequency=1/(60*60) #make the frequency the same as the duration to get one cycle
    points_per_second=10
    max_PAR=400
    wave=generate_sin_wave (total_duration, max_PAR, light_frequency, points_per_second)
    light_pattern['single_sin_wave_1_hr_600_max']=wave
    
    
    #make a single 5-min sin wave with max PAR of 300 uE
    total_duration=5*60 #duration is in seconds, so we do 3600 
    light_frequency=1/total_duration #make the frequency the same as the duration to get one cycle
    points_per_second=100
    max_PAR=300
    wave=generate_sin_wave (total_duration, max_PAR, light_frequency, points_per_second)
    light_pattern['single_sin_wave_5_min_300_max']=wave
    
    
    #make a single one-hour set ot 5-min sin wave with max PAR of 300 uE
    light_pattern['one-hour_sin_wave_5_min_300_max']=multiply_light_pattern(light_pattern['single_sin_wave_5_min_300_max'], 12)
    
    #make a single 1-min sin wave with max PAR of 300 uE
    total_duration=60 #duration is in seconds, so we do 3600 
    light_frequency=1/total_duration #make the frequency the same as the duration to get one cycle
    points_per_second=100
    max_PAR=300
    wave=generate_sin_wave (total_duration, max_PAR, light_frequency, points_per_second)
    light_pattern['single_sin_wave_1_min_300_max']=wave
    
    
    #make a single 10-second sin wave with max PAR of 300 uE
    total_duration=10 #duration is in seconds, so we do 3600 
    light_frequency=1/total_duration #make the frequency the same as the duration to get one cycle
    points_per_second=100
    max_PAR=300
    wave=generate_sin_wave (total_duration, max_PAR, light_frequency, points_per_second)
    light_pattern['single_sin_wave_10_s_300_max']=wave
    
    #make a single one-hour set of 10-sec sin wave with max PAR of 300 uE
    light_pattern['one-hour_sin_wave_10-sec_300_max']=multiply_light_pattern(light_pattern['single_sin_wave_10_s_300_max'], 6*60)
    
    #a one-hour series of square wave pulses at 300 uE
    baseline_duration=75 #75 seconds dark
    baseline_intensity=0 #dark baseline
    pulse_duration=150 #150 seconds pulse
    pulse_intensity=300 #pulse is 300 units
    recovery_duration = 75 #75 seconds recovery
    recovery_intensity=0 #recovery is dark
    rise_time=1 # 1 s for the light to rise or fall
    time_units='seconds' 
    point_frequency=100 #start with a frequency of 100 points per subtrace
    repeat_cycles=12 # The duration of the sin wave was one hour. Each pulse in this wave is 5 min, so do 12 of them
    wave=generate_square_wave_based_light_sequence (baseline_duration, baseline_intensity,
                        pulse_duration, pulse_intensity, recovery_duration, recovery_intensity, 
                        rise_time, time_units, point_frequency, repeat_cycles)
    light_pattern['one_hour_5_min_cycle_square_wave_max_PAR_300']=wave
    
    #a one-hour series of square wave pulses at 300 uE
    baseline_duration=75 #75 seconds dark
    baseline_intensity=0 #dark baseline
    pulse_duration=150 #150 seconds pulse
    pulse_intensity=400 #pulse is 300 units
    recovery_duration = 75 #75 seconds recovery
    recovery_intensity=0 #recovery is dark
    rise_time=1 # 1 s for the light to rise or fall
    time_units='seconds' 
    point_frequency=100 #start with a frequency of 100 points per subtrace
    repeat_cycles=12 # The duration of the sin wave was one hour. Each pulse in this wave is 5 min, so do 12 of them                                        
    wave=generate_square_wave_based_light_sequence (baseline_duration, baseline_intensity,
                        pulse_duration, pulse_intensity, recovery_duration, recovery_intensity, 
                        rise_time, time_units, point_frequency, repeat_cycles)
    light_pattern['one_hour_5_min_cycle_square_wave_max_PAR_600']=wave
    return(light_pattern)

"""
optimized_time_split splits the simulation into small snippets, each with a constant
light intensity, which are simulated in series. This is needed to prevent the sim-
ulations from becoming too stiff for odeint.

"""
def optimized_time_split(test_times_and_light, max_light_change, points_per_segment):   
    test_times_array=test_times_and_light[0]
    test_light=test_times_and_light[1]
    split_points=[] 
    split_begin=0
    sub_arrays_time=[] 
    sub_arrays_light=[]
    split_points.append(0) #start with the zero index split_points

    for i in range(1,len(test_times_array)+1): #test_times_array contains the waveform that will be transformed into
                                                #the appropriate set of sub traces
                                                #the loop progressively increased the length of the selected
                                                #region until the change in light intensity is above the 
                                                #threhold set by max_light_change
        test_range=test_light[split_begin:i]
        if np.max(test_range)- np.min(test_range) > max_light_change: #we have reached the point where the 
                                                                        #light change is larger than the max
            split_points.append(i)
            split_begin=i
    if split_begin<len(test_times_array):
        split_points.append(len(test_times_array)-1)
    for ii in range(1,len(split_points)):
        ptre=split_points[ii]
        ptrb=split_points[ii-1]
        temp_x=np.linspace(test_times_array[ptrb], test_times_array[ptre], points_per_segment)
        #average_light=np.mean(test_light[ptrb:ptre])    #at first, I used the average light intensity over the 
                                                        #entire subtrace, but this was a bad idea because if the 
                                                        #trace was short, it could result in setting the dark baseline
                                                        #to something above zero!
        beginning_light=test_light[ptrb]
        use_this_light=beginning_light
        temp_y=np.linspace(use_this_light, use_this_light, points_per_segment)
        sub_arrays_time.append(temp_x)
        sub_arrays_light.append(temp_y)
    #print('sub_arrays, split_points = ' + str(len(sub_arrays_light)) + ' ' + str(len(split_points)))
    return([sub_arrays_time, sub_arrays_light]) #, split_points])

#def print_constants_table(K):
#    print("{:<30} {:<10}".format('Parameter','Value'))
#    for v in K.items():
#        label, num = v
#        print( "{:<30} {:<10}".format(label, num))

def make_variable_light_constants_set_and_trace_times(K, sub_arrays_time_and_light):
    #K.light_per_L=22
    #print(K.light_per_L)

    sub_arrays_time=sub_arrays_time_and_light[0]
    sub_arrays_light=sub_arrays_time_and_light[1]
    trace_times=[]
    constants_set=[]
    for i in range(len(sub_arrays_time)):
        #print('h ' + str(i))
        K.light_per_L=sub_arrays_light[i][0]
        constants_set.append(K.as_tuple())
        duration=sub_arrays_time[i][-1]-sub_arrays_time[i][0]
        number_of_steps=len(sub_arrays_time[i])
        trace_times.append(np.linspace(0, duration, number_of_steps)) 

    #print('there are ' + str(len(constants_set)) + ' subsets in this trace')
    return([constants_set, trace_times])

def generate_sin_wave(total_duration, max_PAR, light_frequency, points_per_second):
    test_number_points=total_duration*points_per_second
    times_array=np.linspace(0, total_duration, test_number_points, dtype=float)
    sin_wave=[]
    #print('length of test array is: ' + str(len(times_array)))
    for i in times_array:
        sinLt=np.sin(i*2*light_frequency*np.pi-(np.pi/2))
        #sinLt=sinLt+(PAR_offset/max_PAR) #add the offset value, as a fraction of the max_PAR
        sin_wave.append(sinLt)
    sin_wave=np.array(sin_wave)
    sin_wave=sin_wave-np.min(sin_wave)
    if np.max(sin_wave)>0:
        sin_wave=sin_wave/np.max(sin_wave)
    sin_wave=sin_wave*max_PAR
    return([times_array, sin_wave])

    

#*******************************************************************************
#*******************************************************************************
#                   Code related to ODE simulations                            *
#*******************************************************************************
#*******************************************************************************


"""

Notes on the functions calc_K_b6f and calc_v_b6f:
    To estimate the effective rate of PQH2 oxidation at the cytochrome b6f complex, 
    we need to consider the redox states of PQH2, PC as well as the Dy and DpH. 
    Because of the Q-cycle, 2 H+ are transferred into the lumen for each electron 
    passed from PQH2 to PC, i.e. 
    
        0.5PQH2 + b6f(protonated) + PC(ox) --k_b6f--> PQ + b6f(protonated) + PC(red) + 2Hin
    
    The forward rate constant is k_b6f, but the reaction is reversible, so that
    
        0.5PQH2 + b6f(protonated) + PC(ox) <--k_b6f_reverse-- PQ + b6f(protonated) + PC(red) + 2Hin
    
    k_b6f_reverse is a function of pmf because the Q-cycle in the forward direction works against 
    both DpH and Dy. (Note that this thermodynamic effect is in addition to the kinetic effect on 
    the deprotonation of the Rieske protein.) We simplify this for the simulation as follows:
    
        Keq_b6f = Em(Pc_ox/PC_red) - Em(PQ/PQH2) - pmf

    In other words, the eqiulibirum constant is determined by the redox potentials of the donor 
    and acceptor together and the pmf. We use unity as the scaling factor for the pmf 
    contributions becaus ecause one proton translocated to the lumen per e- t
    ransferred (together with one e- charge moved from the p- to the n-side) equilibrium.
    
        k_b6f_reverse = k_b6f / Keq
    
    In principle we could simulate the effects of changing PQH2 and PC redox states in two ways, 
    either using the simulated concentrations of PQH2 and PC together with the standard E'0 values, 
    or accounting for the concentrations in the Em values. We chose the former because 
    it better fits the form of the ODE equations and is a bit simpler to calculate. Thus,
    
        v_b6f=[PQH2][PC_ox]k_b6f - [PQ][PC_red]k_b6f_reverse

    where E'0(Pc_ox/PC_red) = 0.370 V, pH-independent under our conditions; E'0(PQ/PQH2) = 0.11 V at pH=7, 
    but pH-dependent so that: 
        
        E'0(PQ/PQH2) = 0.11 V - (7-pHlumen) * 0.06
        
    at pH=7, but pH-dependent so that:

        Keq_b6f = E'0(Pc_ox/PC_red) - E'0(PQ/PQH2) - pmf = 0.370 - 0.11 + .06 * (pHlumen - 7.0) - pmf

    So, the full set of equations is:
        Em7_PC=0.37 Em_PC=Em7_PC Em7_PQH2 = 0.11 Em_PQH2= Em7_PQH2 + 0.06*(pHlumen-7.0)
    Keq_b6f = 10**((Em_PC - Em_PQH2 - pmf)/.06)
    k_b6f_reverse = k_b6f / Keq
    v_b6f=PQH2PC_oxk_b6f - PQPC_redk_b6f_reverse

"""


def calc_k_b6f(max_b6f, b6f_content, pHlumen, pKreg):    
    #pHmod is the fraction of b6f complex that is deprotonated
    pHmod=(1 - (1 / (10 ** (pHlumen - pKreg) + 1)))
    b6f_deprot=pHmod*b6f_content
    k_b6f=b6f_deprot * max_b6f
    return(k_b6f)

#v_b6f=calc_v_b6f(max_b6f, b6f_content, pHlumen, pKreg, PQ, PQH2, PC_ox, PC_red, Em7_PC, Em7_PQH2, pmf)

def calc_v_b6f(max_b6f, b6f_content, pHlumen, pKreg, PQ, PQH2, PC_ox, PC_red, Em7_PC, Em7_PQH2, pmf):    
    pHmod=(1 - (1 / (10 ** (pHlumen - pKreg) + 1)))
    b6f_deprot=pHmod*b6f_content

    Em_PC=Em7_PC
    Em_PQH2= Em7_PQH2 - 0.06*(pHlumen-7.0)

    Keq_b6f = 10**((Em_PC - Em_PQH2 - pmf)/.06)
    k_b6f=b6f_deprot * max_b6f 

    k_b6f_reverse = k_b6f / Keq_b6f
    #print('Keq for PQH2 to PC + pmf is: ' + str(Keq_b6f))
    f_PQH2=PQH2/(PQH2+PQ) #want to keep the rates in terms of fraction of PQHs, not total number
    f_PQ=1-f_PQH2
    v_b6f=f_PQH2*PC_ox*k_b6f - f_PQ*PC_red*k_b6f_reverse 
    return(v_b6f)


#calculate the rate of V<-- -->Z reactions, assuming a pH-dependent VDE and a pH-independent ZE
def calc_v_VDE(VDE_max_turnover_number, pKvde, VDE_Hill, kZE, pHlumen, V, Z):    

    #VDE_Hill is the Hill coefficient for the VDE reaction
    #pKvde is the pKa for protonation of VDE
    #VDE_max_turnover_number is the maximum turnover rate (at low pH for VDE)
    #kZE is the rate constant for the ZE reaction

    #pHmod is the fraction of VDE complex that is deprotonated
    pHmod=1-(1 - (1 / (10 ** (VDE_Hill*(pHlumen - pKvde)) + 1)))
    
    #pHmod=1-(1 - (1 / (10 ** (VDE_Hill*(pHlumen - pKvde) + 1))))
    #pHmod=(1-(1 / (10 ** (VDE_Hill*(pHlumen - pKvde) + 1))))
    #print(pHmod)
    #calculate the net change in Z
    v_Z = V* VDE_max_turnover_number*pHmod - Z*kZE
    v_V = -1* v_Z
    
    return(v_Z, v_V)
    
#calculate the rate of V<-- -->Z reactions, assuming a pH-dependent VDE and a pH-independent ZE
def calc_PsbS_Protonation(pKPsbS, pHlumen):    

    #VDE_Hill is the Hill coefficient for the VDE reaction
    #pKvde is the pKa for protonation of VDE
    #VDE_max_turnover_number is the maximum turnover rate (at low pH for VDE)
    #kZE is the rate constant for the ZE reaction

    #pHmod is the fraction of VDE complex that is deprotonated
    PsbS_H=1-(1 - (1 / (10 ** ((pHlumen - pKPsbS)) + 1)))
    
    return(PsbS_H)

"""

ATP synthase pmf + ADP + Pi --gHplus--> ATP   
I use a very simple model, described in the following:
The flux gthrough an active ATP synthase is roughly Ohmic
with an intrinsive slope (gH+)  protons per second per volt pmf. 

From Takizawa et al:

K. Takizawa, A. Kanazawa, J.A. Cruz, D.M. Kramer (2007) 
In vivo thylakoid proton motive force.  Quantitative non-
invasive probes show the relative lumen pH-induced regulatory 
responses of antenna and electron transfer. Biochim Biophys 
Acta 1767 1233–1244.

We get about 3 H+/mV, so:
 gH_plus_int= 3000 H+/s.V

However, one may also consider that there is a maximal (saturating turover rate 
(saturation point), as shown by Junesch and Grabber (1991)
http://dx.doi.org/10.1016/0014-5793(91)81447-G
Their data shows a roughly n=1 pmf-dependence, similar to a pH titration curve, but for pmf, which can 
be simulated by changing the code to include this term.
    
"""

def Vproton(ATP_synthase_max_turnover, n, pmf, pmf_act):
    return (ATP_synthase_max_turnover*n*(1 - (1 / (10 ** ((pmf - pmf_act)/.06) + 1))))

"""
# Calc_Phi2 gives an estiamte of Phi2 based on QA redox state
# and NPQ. The dertivation of the equation is based on that described in


D.M. Kramer, G. Johnson, O. Kiirats, G.E. Edwards (2004) New fluorescence 
parameters for the determination of QA redox state and excitation energy fluxes. 
Photosynthesis research 79, 209-218.

and

S. Tietz, C.C. Hall, J.A. Cruz, D.M. Kramer (2017) NPQ(T): a chlorophyll fluorescence p
arameter for rapid estimation and imaging of non-photochemical quenching of excitons i
n photosystem II associated antenna complexes. Plant Cell and Environment In Press.


The following is a derivation for determining Phi2 from NPQ and QA redox state
Recall that NPQ is the ratio of:
    
    NPQ=kNPQ/(kd+kf)

    and

    kNPQ=NPQ/(kf+kd)

    where kNPQ if the rate constant for NPQ, kq is the k for intrinsic non-radiative, and kf is the rate constant for fluorescence

The maximal PSII quantum yield is:

    Phi2_max = kpc/(kd + kf +kpc) = 0.83

    where kpc is the maximal rate contant for quenching of excitation energy by open PSII
and thus: 
    Phi2 = QAkpc/(kf + kd + kNPQ + QAkpc) = QAkpc/(kf + kd + NPQ/(kf+kd) + QAkpc) 
            = QAkpc/(kf + kd + NPQ/(kf+kd) + QAkpc)
        
    1/Phi2= (kd + kf + kNPQ + QAkpc)/QAkpc = 1 + (kd+kf+ kNPQ)/QAkpc
            = 1 + (kf+kd)/QAkpc + kNPQ/QAkpc 1/(PHI2(kf+kd)) 
            = 1/(kf+kd) + 1/(QAkpc) + kNPQ/((kf+kd)QAkpc) 1/(PHI2(kf+kd)) 
            = 1/(kf+kd) + 1/(QAkpc) + NPQ/QAkpc
            = 1/(kf+kd) + 1/(QA*kpc) + NPQ/(QA*kpc)
            
    1/Phi2_max = (kd + kf)/kd +kpc/kpc 
                = 1+ (kf + kd)/kpc 0.83-1 
                = (kf + kd)/kpc =0.17 kpc/(kf+kd)=5.88
                
    kpc/(PHI2(kf+kd)) = kpc/(kf+kd) + kpc/(QAkpc) + kpcNPQ/QAkpc
    
    5.88/Phi2 = 5.88 + 1/QA + NPQ/QA = 5.88 + (1+NPQ)/QA 1/Phi2=1 + (1+NPQ)/(5.88*QA)
    Phi2=1/(1+(1+NPQ)/(5.88*QA))

   = 1
   ____________
   1+ (1+NPQ)
      _______
      5.88*QA


"""

def Calc_Phi2(QA, NPQ):
    Phi2=1/(1+(1+NPQ)/(4.88*QA))
    return Phi2

"""
Calc_PhiNO_PhiNPQ gives estiamtes of PhiNO and PhiNPQ based on the
equations is based on that described in

D.M. Kramer, G. Johnson, O. Kiirats, G.E. Edwards (2004) New fluorescence 
parameters for the determination of QA redox state and excitation energy fluxes. 
Photosynthesis research 79, 209-218.

S. Tietz, C.C. Hall, J.A. Cruz, D.M. Kramer (2017) NPQ(T): a chlorophyll fluorescence 
parameter for rapid estimation and imaging of non-photochemical quenching of excitons in 
photosystem II associated antenna complexes. Plant Cell and Environment In Press.

and derived using the approach detailed for Phi2.

"""

def Calc_PhiNO_PhiNPQ(Phi2, QA, NPQ):
    PhiNO=1/(1+NPQ + ((Phi2+NPQ)/(1-Phi2)))
    PhiNPQ=1-(Phi2+PhiNO)
    return PhiNO, PhiNPQ


"""
Notes on calculation of PSII recombination rates:
    
    I used the equations presented in Davis et al. 2016 

G.A. Davis, A. Kanazawa, M.A. Schöttler, K. Kohzuma, J.E. Froehlich, A.W. 
Rutherford,M. Satoh-Cruz, D. Minhas, S. Tietz, A. Dhingra, D.M. Kramer 
(2016) Limitations to photosynthesis by proton motive force-Induced 
photosystem II photodamage eLife eLife 2016;5:e16921.

Specifically,there are two parts to the estimation of rates of recombination:
    
    v_recombination = k_recomb*QAm*(10**(Dy/.06) + fraction_pH_effect*10**(7.0-pHlumen))

    where k_recomb is the rate constant for S2QA- recombination in the 
    absence of a field in s^-1. Dy is the delta_psi in volts, QAm is the 
    content of reduced QA~0.33 or one recombination per 3 s, s seen in the 
    presence of DCMU. The term fraction_pH_effect rtepresents the fraction 
    of S-states that are both pH-sensitive i.e. involve release of protons, 
    and are unstable (can recombine).

Then, 10**(7.0-pHlumen) represents the change in equilibrium constant
for the Sn+1 P680 <--> SnP680+, as a result of changes in lumen pH 

"""

def recombination_with_pH_effects(k_recomb, QAm, Dy, pHlumen, fraction_pH_effect):
    delta_delta_g_recomb= Dy + .06*(7.0-pHlumen)
    v_recomb = k_recomb*QAm*10**(delta_delta_g_recomb/.06)
    
    #v_recomb = k_recomb*QAm*(10**((Dy/.06) + fraction_pH_effect*10**(7.0-pHlumen)))
    
    
    return(v_recomb)


#Function f calculates the changes in state for the entire systems

def f(y, t, pKreg, max_PSII, kQA, max_b6f, lumen_protons_per_turnover, PAR, ATP_synthase_max_turnover, 
    pHstroma, antenna_size, Volts_per_charge, perm_K, n, Em7_PQH2, Em7_PC, PSI_antenna_size, 
    buffering_capacity, VDE_max_turnover_number, pKvde, VDE_Hill, kZE, pKPsbS, max_NPQ, k_recomb, k_PC_to_P700, 
    triplet_yield, triplet_to_singletO2_yield, fraction_pH_effect, k_Fd_to_NADP, k_CBC, k_KEA): 

    #The following are holders for paramters for testing internal functions of f
    light_per_L=PAR
    
    #Transfer the dependent parameters (things that change)
    QA, QAm, PQ, PQH2, Hin, pHlumen, Dy, pmf, deltaGatp, Klumen, Kstroma, ATP_made, PC_ox, PC_red, P700_ox, P700_red, Z, V, NPQ, singletO2, Phi2, LEF, Fd_ox, Fd_red, ATP_pool, ADP_pool, NADPH_pool, NADP_pool =y
    
    PSII_recombination_v=recombination_with_pH_effects(k_recomb, QAm, Dy, pHlumen, fraction_pH_effect)
        
    dsingletO2=PSII_recombination_v*triplet_yield*triplet_to_singletO2_yield


    #calculate pmf from Dy and deltapH 
    pmf=Dy + 0.06*(pHstroma-pHlumen)

    #***************************************************************************************
    #PSII reations
    #****************************************************************************************
    #first, calculate Phi2
    Phi2=Calc_Phi2(QA, NPQ) #I use the current' value of NPQ. I then calculate the difference below 

    #calculate the number of charge separations in PSII per second
    PSII_charge_separations=light_per_L * Phi2 - PSII_recombination_v
    
    #The equilibrium constant for sharing electrons between QA and the PQ pool
    #This parameter will be placed in the constants set in next revision
    
    Keq_QA_PQ=200
    
    #calculate the changes in QA redox state based on the number of charge separations and equilibration with 
    #the PQ pool
    dQAm = PSII_charge_separations  + PQH2*QA*kQA/Keq_QA_PQ  - QAm * PQ * kQA - PSII_recombination_v
    dQA = -1*dQAm

    #***************************************************************************************
    #PQ pool and the cyt b6f complex
    #***************************************************************************************

    #vb6f = k_b6f(b6f_max_turnover_number, b6f_content, pHlumen, pKreg, PQH2)

    #b6f_content describes the relative (to standaard PSII) content of b6f 
    #This parameter will be placed in the constants set in next revision
    b6f_content=1
    
    #calc_v_b6f return the rate of electron flow through the b6f complex
    v_b6f=calc_v_b6f(max_b6f, b6f_content, pHlumen, pKreg, PQ, PQH2, PC_ox, PC_red, Em7_PC, Em7_PQH2, pmf)

    #calculate the change in PQH2 redox state considering the following:
    #PQ + QAm --> PQH2 + QA ; PQH2 + b6f --> PQ    
    dPQH2 = QAm * PQ * kQA - v_b6f - + PQH2*QA*kQA/Keq_QA_PQ 
    dPQ = -1*dPQH2

    #***************************************************************************************
    #PSI and PC reactions:
    #***************************************************************************************

    #Calculate the changes in PSI redox state. The current form is greatly simplified, 
    #but does consider the need for oxidized Fd.
    #At this point, I assumed that the total Fd pool is unity
    
    PSI_charge_separations= P700_red * light_per_L * PSI_antenna_size * Fd_ox 
    
    #P700 reactions
    d_P700_ox = PSI_charge_separations - PC_red * k_PC_to_P700 * P700_ox
    d_P700_red=-1*d_P700_ox
    
    #PC reactions:
    d_PC_ox = PC_red * k_PC_to_P700 * P700_ox - v_b6f
    d_PC_red = -1*d_PC_ox
    
    dFd_red=PSI_charge_separations - k_Fd_to_NADP*Fd_red*NADP_pool
    dFd_ox=-1*dFd_red
    
    dNADPH_pool=k_Fd_to_NADP*NADP_pool*Fd_red - NADPH_pool*k_CBC
    dNADP_pool=-1*dNADPH_pool
    
    dLEF=k_Fd_to_NADP*NADP_pool*Fd_red
    
    #***************************************************************************************
    # ATP synthase reactions:
    #***************************************************************************************
    #the following is based on a simple linear m_l where the rate of ATP synthase is saimply 
    #governed by the driving force, i.e. pmf-DGatp/n
    # a more complex model, which has both pmf threshold and max rate is described in the following:
    #    def Vproton(ATP_synthase_max_turnover, n, pmf, pmf_act):
    #    return (ATP_synthase_max_turnover*n*(1 - (1 / (10 ** ((pmf - pmf_act)/.06) + 1))))
    #vHplus=Vproton(ATP_synthase_max_turnover, n, pmf, pmf_act)
    
    ATP_synthase_driving_force=pmf-(deltaGatp/n) #this is positive if pmf is sufficient to drive 
                                                #reaction forward
                                                
    d_protons_to_ATP = ATP_synthase_max_turnover*n*ATP_synthase_driving_force 
        
    d_ATP_made=d_protons_to_ATP/n                                        
    
    
    #***************************************************************************************
    #Proton input (from PSII, b6f and PSI) and output (ATP synthase) reactions :
    #***************************************************************************************
    #calculate the contributions to lumen protons from PSII, assuming a average of 
    #one released per S-state transition. In reality, the pattern is not 1:1:1:1, 
    #but for simplicity, I am assuming that the S-states are scrambled under our 
    #illumination conditions. This is described in more detail in the manuscript.
    
    d_protons_from_PSII = PSII_charge_separations - PSII_recombination_v

    #calculate the contributions to Dy from PSII
    charges_from_PSII = PSII_charge_separations - PSII_recombination_v
    
    #calculate the contributions to lumen protons from b6f complex
    #assuming the Q-cycle is engaged, asn thus
    #two protons are released into lumen per electron from
    #PQH2 to PC
    """
    C.A. Sacksteder, A. Kanazawa, M.E. Jacoby, D.M. Kramer (2000) The proton to electron 
    stoichiometry of steady-state photosynthesis in living plants: A proton-pumping Q-cycle 
    is continuously engaged. Proc Natl Acad Sci U S A 97, 14283-14288.

    """
    d_protons_from_b6f = v_b6f*2 #two protons per electron transferred from PQH2 to PC

    #calculate the contributions to Dy from Q-cycle turnover
    #one charge through the low potential b chain per
    #PQH2 oxidized
    charges_from_b6f = v_b6f
     
    #add up the changes in protons delivered to lumen
    #note: net_protons_in is the total number of protons input into the lumen, including both free and bound.
    net_protons_in = d_protons_from_PSII + d_protons_from_b6f - d_protons_to_ATP
    
    

    #***************************************************************************************
    #Movement of K+ in response to Dy and K+ gradient
    #***************************************************************************************    
    #K_Keq=(Kstroma/Klumen)*10**(-1*Dy/.06)

    #Caluclate the fluxes of counterions,
    #in this case, chosing a representative cation, K+
    #The equation considers both the Dy, differences
    #ion K+ concentrations in lumen and stroma
    # and permeability

    #First, calculate the delta.mu(squiggle).K+
    #For example, say Kstroma is .02 and Klumen is .002 
    #then this favors lumen-movement of K
    #with a delta_G of .06 V
    #which would be balanced by a +.06 V pmf
    
    #***********K_deltaG=(.06*np.log10(Kstroma/Klumen) - Dy)

    #Next, use this to calculate a flux, which depends
    #on the permeability of the thylakoid to K+, perm_K:
    #*********** net_Klumen = perm_K * K_deltaG*(Klumen+Kstroma)/2
    
    #if Dy is +60 mV, then at equilibrium, Kstroma/Klumen should be 10, at which point Keq=1.
    #the Keq is equal to kf/kr, so the rato of fluxes is 
    
    
#    net_Klumen=perm_K * K_Keq - perm_K/K_Keq 
    #calculate the change in lumen [K+] by multiplying the change in K+ ions
    #by the factor lumen_protons_per_turnover that relates the standard
    #complex concentration to volume:
    #the term is called "lumen_protons_per_turnover" but is the same for 
    #all species
        
   #*********** dKlumen = net_Klumen*lumen_protons_per_turnover
    
    #We assume that the stromal vaolume is large, so there should be 
    #no substantial changes in K+
    
    #***********dKstroma=0 


    ##############################revised form that includes KEA3 H+/K+ antiporter
    
    
    #K_Keq=(Kstroma/Klumen)*10**(-1*Dy/.06)

    #Caluclate the fluxes of counterions,
    #in this case, chosing a representative cation, K+
    
    #The equation considers both the Dy, differences
    #ion K+ concentrations in lumen and stroma
    # and permeability
    
    #In this case, we now eplicitely include a H+/K+ antiporter

    #First, calculate the delta.mu(squiggle).K+
    #For example, say Kstroma is .02 and Klumen is .002 
    #then this favors lumen-movement of K
    #with a delta_G of .06 V
    #which would be balanced by a +.06 V pmf
    
    K_deltaG=(.06*np.log10(Kstroma/Klumen) - Dy)
    
    #the KEA reaction looks like this:
    # H+(lumen) + K+(stroma) <-- --> H+(stroma) + K+(lumen)
    #and the reaction is electroneutral, 
    #so the forward reaction will depend on DpH and DK+ as:
    
    Hlumen = 10**(-1*pHlumen)
    Hstroma = 10**(-1*pHstroma)
    v_KEA = k_KEA*(Hlumen*Kstroma -  Hstroma*Klumen)

    #Next, use this to calculate a flux, which depends
    #on the permeability of the thylakoid to K+, perm_K:
    net_Klumen = perm_K * K_deltaG*(Klumen+Kstroma)/2 + v_KEA
    
    #if Dy is +60 mV, then at equilibrium, Kstroma/Klumen should be 10, at which point Keq=1.
    #the Keq is equal to kf/kr, so the rato of fluxes is 
    
    
    #net_Klumen=perm_K * K_Keq - perm_K/K_Keq 
    #calculate the change in lumen [K+] by multiplying the change in K+ ions
    #by the factor lumen_protons_per_turnover that relates the standard
    #complex concentration to volume:
    #the term is called "lumen_protons_per_turnover" but is the same for 
    #all species
        
    dKlumen = net_Klumen*lumen_protons_per_turnover
    
    #We assume that the stromal vaolume is large, so there should be 
    #no substantial changes in K+
    
    dKstroma=0 
    
    #***************************************************************************************
    #Buffering capacity and calculation of lumen pH:
    #***************************************************************************************
    # Here, we convert d_protons_in into a "concentration" by dividing by the volumen
    dHin = net_protons_in*lumen_protons_per_turnover - v_KEA
    
    # Here we calculate the change in lumen pH by dividing dHin by the buffering capacity
    dpHlumen= -1*dHin / buffering_capacity 


    #***************************************************************************************
    #Calculation of Dy considering all ion movements and thylakoid membrane capatitance
    #***************************************************************************************
    delta_charges=charges_from_PSII+PSI_charge_separations + charges_from_b6f + net_Klumen - d_protons_to_ATP
                
    #delta_charges= net_protons_in + net_Klumen # - PSII_recombination_v 
    # recall that PSII_recnotesombination is negative electrogenic 
    #note, I now inclluded this term in the calculation of PSII charge separations

    dDy=delta_charges*Volts_per_charge
    dpmf= .06* dpHlumen + dDy 

    #calculate changes to deltaGatp
    #assume that deltaGatp is constant (as suggested by past resarch)...is this changes, 
    #need to consider many metabilic reactions as well
    ddeltaGatp=0 
                
    #calculate changes in the concentrations of zeaxanthin (Z) and violaxanthin (V)
    #considering VDE_max_turnover_number, pKvde, VDE_Hill, kZE, and lumen pH
    
    dZ, dV = calc_v_VDE(VDE_max_turnover_number, pKvde, VDE_Hill, kZE, pHlumen, V, Z)

    #***************************************************************************************
    #The following calculated changes in NPQ based on the previous and new lumen pH
    #***************************************************************************************

    #calculate the protonation state of PsbS, considering 
    #its pKa and lumen pH
    
    new_PsbS_H = calc_PsbS_Protonation(pKPsbS, pHlumen + dpHlumen)
    new_Z=Z+dZ
    
    #calculate NPQ, based on a simple relationahip between
    #the concentration of Z and the protonation state of PsbS
    new_NPQ=max_NPQ*new_PsbS_H*new_Z
    
    #feed this into odeint by calculating the change in NPQ compared to the previous
    #time point
    dNPQ=new_NPQ-NPQ #new_PsbS_H-PsbS_H

    #we re-calculate Phi2 at the start of each iteration of f, so we do not want 
    #odeint to change it
    dPhi2=0 #

    #Calculate changes in the concentrations of ATP and ADP.
    #for the moment, the consumption of ATP is equal to its production,
    #so there should be no net changes.
    dATP_pool=0
    dADP_pool=0

    return [dQA, dQAm, dPQ, dPQH2, dHin, dpHlumen, dDy, dpmf, ddeltaGatp, dKlumen, dKstroma, 
            d_ATP_made, d_PC_ox, d_PC_red, d_P700_ox, d_P700_red, dZ, dV, dNPQ, dsingletO2, dPhi2, dLEF, 
            dFd_ox, dFd_red,  dATP_pool, dADP_pool, dNADPH_pool,dNADP_pool]
            

#log_progress displays a tiem bar so the users know how long they have to wait
#for thersults.

def log_progress(sequence, every=None, size=None):

    is_iterator = False
    if size is None:
        try:
            size = len(sequence)
        except TypeError:
            is_iterator = True
    if size is not None:
        if every is None:
            if size <= 200:
                every = 1
            else:
                every = int(size / 200)     # every 0.5%
    else:
        assert every is not None, 'sequence is iterator, set every'

    if is_iterator:
        progress = IntProgress(min=0, max=1, value=1)
        progress.bar_style = 'info'
    else:
        progress = IntProgress(min=0, max=size, value=0)
    label = HTML()
    box = VBox(children=[label, progress])
    display(box)

    index = 0
    try:
        for index, record in enumerate(sequence, 1):
            if index == 1 or index % every == 0:
                if is_iterator:
                    label.value = '{index} / ?'.format(index=index)
                else:
                    progress.value = index
                    label.value = u'{index} / {size}'.format(
                        index=index,
                        size=size
                    )
            yield record
    except:
        progress.bar_style = 'danger'
        raise
    else:
        progress.bar_style = 'success'
        progress.value = index
        label.value = str(index or '?')
        
#do_comple_sim does just what it's name says.
#The user sends the initial states (y), the 
#the constants_set_and_trace_times, whcih contains the timing and 
#light intensity (and in the future other parameters),
#and the set of constants (Kx) to use for the simulaitons


def sim(K, initial_states, pulse_times_and_light, max_light_change, points_per_segment, **keyword_parameters):
    
    if ('dark_equilibration' in keyword_parameters):
        equibrate_time= keyword_parameters['dark_equilibration']
        use_initial_states=dark_equibration(initial_states, K, equibrate_time)
    else:
        use_initial_states=initial_states
    sub_arrays_time_and_light= optimized_time_split(pulse_times_and_light, 
                                max_light_change, points_per_segment) 

    #first make the constants_set and trace_times for the split segments

    constants_set_and_trace_times=make_variable_light_constants_set_and_trace_times(K, sub_arrays_time_and_light)

    #next, do the simulation
    output=do_complete_sim(use_initial_states, constants_set_and_trace_times, K)
    return(output, use_initial_states)


def do_complete_sim(y, constants_set_and_trace_times, Kx):
    from ipywidgets import FloatProgress
    #from IPython.display import display
    
    y[11]=0 #set ATP_made to zero
    
    # (re)set the arrays to nothing
    constants_set=constants_set_and_trace_times[0]
    trace_times=constants_set_and_trace_times[1]

    # prepare a dictionary with empty arrays to store output
    output={}
    for label in species_labels:
        output[label] = []
    time_axis=[]
    
    #initial the progress bar display    
    prog_bar = FloatProgress(min=0, max=len(constants_set))
    display(prog_bar)
    
    #Iterate through the constants_set list, one set of values for each 
    #subtrace, during which the light intensity is held constant    
    for index, constants in enumerate(constants_set):
        prog_bar.value = index
        t=trace_times[index]
        
        #Currently, the pHstroma is assumed to be constant over the time 
        #of the sub trace.Therefore it appears in both the constants and  
        #the states.
        pHstroma=constants[7] 
        
        # The following sets the initial conditions to the values at the end of the previous run 
        # odeint is the function that performs the ODE calculations.
        
        soln = odeint(f, y, t, args=constants)
        
        #Set the next y value using the final values from the current simulation.
        y=list(soln[-1,:])

        # Fix the problem with zero time difference between runs.
        if index>0:
            time_axis = np.append(time_axis, t+time_axis[-1])
        else:
            time_axis = t
            
        #append a set of computed constants to the output arrays
        for index, label in enumerate( species_labels ):
            output[label] = np.append( output[label], soln[:,index] )

    # save the results in case we want to start another simulation that starts where this one left off
    end_state = list(soln[-1,:])

    #The following section calculates a number of new parameters from the simulaiton data
        
    # Calculate pmf_total from Dy and delta_pH
    Dy = output['Dy']
    pHlumen = output['pHlumen']
    pmf_total= Dy + ((pHstroma-pHlumen)*.06)
    
    # calculate the Phi2 values based on simulation output parameters

    Phi2_array=[] #contains the calculated Phi2 results
    QA = output['QA']
    NPQ_array = output['NPQ_array']
    for i in range(len(QA)):
        Phi2_array.append(Calc_Phi2(QA[i], NPQ_array[i]))
        
    #calculate tPhiNO and PhiNPQ
    # using the Calc_PhiNO_PhiNPQ function.
    PhiNPQ_array=[]
    PhiNO_array=[]
    for i in range(len(QA)):
        PhiNO, PhiNPQ=Calc_PhiNO_PhiNPQ(Phi2_array[i], QA[i], NPQ_array[i])
        PhiNPQ_array.append(PhiNPQ)
        PhiNO_array.append(PhiNO)
    output['PhiNPQ']=PhiNPQ_array
    output['PhiNO']=PhiNO_array
    
    #Set up an array to contain the light curve (the PAR values), 
    light_curve=[]    
    for i in range(0,len(trace_times)):
        light=constants_set[i][5]
        for i in range(0,len(trace_times[i])):
            light_curve.append(light)

    # compute LEF array from Phi2 and light (does not consider recombination!)
    LEF_array_from_Phi2=[]
    PSII_cross_section=0.45
    for i in range(0,len(Phi2_array)):
        LEF_array_from_Phi2.append(light_curve[i]*Phi2_array[i]*PSII_cross_section)
    
    LEF_array_from_Phi2=[]
    PSII_cross_section=0.45
    for i in range(0,len(Phi2_array)):
        LEF_array_from_Phi2.append(light_curve[i]*Phi2_array[i]*PSII_cross_section)

    # calculate singletO2_rate
    singletO2_array = output['singletO2_array']
    singletO2_rate=[]
    singletO2_rate.append(0)
    for i in range(1,len(singletO2_array)):
        so2r=(singletO2_array[i]-singletO2_array[i-1])/(time_axis[i]-time_axis[i-1])
        singletO2_rate.append(so2r)
        
    # in singletO2_rate, get rid of nans when the delta_t was zero; replace with previous value
    for i in range(1,len(singletO2_rate)):
        if np.isnan(singletO2_rate[i]):
            singletO2_rate[i]=singletO2_rate[i-1]

    # compute delta_pH and delta_pH_V
    delta_pH=[]
    delta_pH_V=[]
    #fraction_Dy=[]
    for i in range(0,len(pHlumen)):
        dpH=pHstroma-pHlumen[i]
        dpH_V=dpH*.06
        delta_pH.append(dpH)
        delta_pH_V.append(dpH_V)

    # before returning output, append the computed data
    # the output already includes all the results directly from odeint(f, ... )
    
    output['delta_pH']=delta_pH
    output['delta_pH_V']=delta_pH_V   
     
    output['pmf']=pmf_total

    output['delta_pH_offset']=delta_pH-delta_pH[0]
    output['delta_pH_V_offset']=delta_pH_V-delta_pH_V[0]    
    output['pmf_offset']=pmf_total-pmf_total[0]
    output['Dy_offset']=Dy-Dy[0]
    
    #output['deltaGatp']=deltaGatp
    output['pmf_total']=pmf_total
    output['singletO2_rate']=singletO2_rate
    output['time_axis']=time_axis
    output['time_axis_min']=time_axis/60
    output['time_axis_h']=time_axis/3600
    output['end_state'] = end_state
    output['light_curve'] = light_curve
    integrated_light=[]
    il_cum=0.0
    integrated_light.append(il_cum)
    for indexl in range(1, len(light_curve)):
        il_cum=il_cum+light_curve[indexl]*(time_axis[indexl]-time_axis[indexl-1])
        integrated_light.append(il_cum)
    output['integrated_light']=integrated_light
    output['fraction_Dy']=Dy/pmf_total
    output['fraction_DpH']=delta_pH_V/pmf_total
    
    # Some of the values are 
    # duplicates of existing results, with different keys. 
    # Shouldn't be necessary, but I'm leaving this in for now because
    # other function may be expecting these keys

    output['Z']=output['Z_array'] 
    output['V']=output['V_array'] 
    output['NPQ']=NPQ_array 
    output['singletO2']=singletO2_array 
    output['Phi2'] = Phi2_array
    
    output['LEF'] = output['LEF_array'] #LEF_array_from_Phi2 #output['LEF_array']    
    output['LEF_productive']=[] #output['LEF_array']
    output['LEF_productive'].append(0)

    for i in range(1,len(output['LEF_array'])):
        temp=(output['LEF_array'][i]-output['LEF_array'][i-1])/(time_axis[i]-time_axis[i-1])
        output['LEF_productive'].append(temp)

    #calculate the electron flow to NADPH
    output['LEF_to_NADPH']=[0]
    #output['LEF_to_NADPH'].append(0)
    for i in range(1,len(output['LEF_array'])):
        temp=(output['LEF_array'][i]-output['LEF_array'][i-1])/(time_axis[i]-time_axis[i-1])
        output['LEF_to_NADPH'].append(temp)
    output['LEF_to_NADPH']=np.array(output['LEF_to_NADPH']) #convert to np array so we can do calculations below
    
    LEF_cumulative=[]
    LEF_cumulative.append(0)
    LEF_cum=0
    
    #calculate the rate of ATP formation, by taking the derivative of the total ATP
    #accumulation
    
    ATP_rate=[0]
    for i in range(1, len(output['LEF'])):
        LEF_cum=LEF_cum+(output['LEF'][i] * (output['time_axis'][i]-output['time_axis'][i-1]))
        LEF_cumulative.append(LEF_cum)
        q1=np.array(output['ATP_made'][i])-np.array(output['ATP_made'][i-1])
        q2=np.array(output['time_axis'][i])-np.array(output['time_axis'][i-1])
        delta_ATP=(q1/q2)
        ATP_rate.append(delta_ATP)
    normalized_LEF_cumulative=LEF_cumulative/LEF_cumulative[-1]
    output['LEF_cumulative']=output['LEF_array'] #LEF_cumulative
    output['normalized_LEF_cumulative']=normalized_LEF_cumulative
    output['ATP_rate']=np.array(ATP_rate)
    NADPH=np.array(output['LEF'], dtype=float)/2
    output['NADPH']=NADPH
    
    #output the PsbS protonation state, and the control of electron flow
    #at the cytochrome b6f complex.
    
    output['PsbS_protonated']=[]
    output['b6f_control']=[]
    for pH in output['pHlumen']:
        output['PsbS_protonated'].append(calc_PsbS_Protonation(Kx.pKPsbS, pH))
        output['b6f_control'].append(calc_k_b6f(Kx.max_b6f,1, pH, Kx.pKreg))
        
    #Calculate and store the rate of Fd reduction
    Fd_rate=[0]
    for index in range(1,len(output['Fd_red'])):
        Fd_rate.append((output['Fd_red'][index]-output['Fd_red'][index-1])/(output['time_axis'][index]-output['time_axis'][index-1]))
    output['Fd_rate']=np.array(Fd_rate)
    output['ATP/NADPH']= 2*output['ATP_rate']/(output['Fd_rate'])
    
    ##calculate and store the net fluxes of the counterion K+ into the lumen.
    #K_flux=[0]
    #for i in range(1,len(output['Klumen'])):
    #    K_flux.append((output['Klumen'][i-1]-output['Klumen'][i])/(output['time_axis'][i]-output['time_axis'][i-1]))
    #    
    #output['K_flux']=np.array(K_flux)
    #output['K_flux_normalized']=output['K_flux']/Kx.lumen_protons_per_turnover
    
    #calculate the fluxes of counter-ions and the ratio of LEF_to_NADPH production
    K_flux=[0] #start with zero because we will be calculating the derivative
    for i in range(1,len(output['Klumen'])):
        K_flux.append((output['Klumen'][i-1]-output['Klumen'][i])/(output['time_axis'][i]-output['time_axis'][i-1]))

    output['K_flux']=np.array(K_flux)
    output['K_flux']=output['K_flux']/Kx.lumen_protons_per_turnover
    
    
    # output['LEF_productive']=np.array(output['LEF_productive'])
    # Eliminate nans in the ratio calculations. These occur when flux is zero, when the 
    # ratio is undefined
    for i in range(len(output['ATP_rate'])):
        if np.isnan(output['LEF_to_NADPH'][i]):
            output['LEF_to_NADPH'][i]=output['LEF_to_NADPH'][i-1]
        if np.isnan(output['ATP_rate'][i]):
            output['ATP_rate'][i]=output['ATP_rate'][i-1]
        if np.isnan(output['K_flux'][i]):
            output['K_flux'][i]=output['K_flux'][i-1]

    # calculate the deficit in ATP/NADPH and store it in output['deficit']
    output['deficit']=(output['LEF_to_NADPH']*(3.0/Kx.n)-output['ATP_rate'])  
    output['deficit_int']=integrate.cumtrapz(output['deficit'], output['time_axis'], initial=0)
    output['fract_deficit']=output['deficit_int']/output['LEF_to_NADPH']

    return(output)

# The following coducts a dark equilibration simulation, to allow the system to achieve 
# a steady, dark conditions. 

def dark_equibration(y_initial, Kx, total_duration, **keyword_parameters): 
    #make a sin wave with zero amplitude
    light_frequency=1/total_duration
    points_per_second=10
    max_PAR=0
    dark_time_light_profile=generate_sin_wave(total_duration, max_PAR, light_frequency, points_per_second)
    max_light_change=10
    points_per_segment=100
    optimized_dark_sub_arrays= optimized_time_split(dark_time_light_profile, 
        max_light_change, points_per_segment) 

    #Generate the constants_set and trace_times for the split segments
    constants_set_and_times=make_variable_light_constants_set_and_trace_times(Kx, optimized_dark_sub_arrays)
    
    #next, do the simulation
    output=do_complete_sim(y_initial, constants_set_and_times, Kx)

    #store the final state in  dark_equilibrated_initial_y
    dark_equilibrated_initial_y=output['end_state']

    if ('return_kinetics' in keyword_parameters) and keyword_parameters['return_kinetics']==True:
        return(dark_equilibrated_initial_y, output)
    else:
        return(dark_equilibrated_initial_y)


#*******************************************************************************
#*******************************************************************************
#                   Code related to plotting out results                       *
#*******************************************************************************
#*******************************************************************************


# The plot_interesting_stuff function plots out several graphs
# that show interesting or important results
# It is not meant to output final results

def plot_interesting_stuff(figure_name, output):
    #matplotlib.rcParams.update['figure.figsize'] = [10, 8]
    #light=output['light_curve']
    ltc='red'
    plt.rcParams.update({'font.size': 5})
    time_axis_seconds=output['time_axis']
    max_time=np.max(time_axis_seconds)
    if max_time/(60*60)>1:    
        time_axis=time_axis_seconds/(60*60)
        time_label='Time (h)'
    elif max_time/(60)>1:
        time_axis=time_axis_seconds/(60)
        time_label='Time (min)'
    else:
        time_axis=time_axis_seconds
        time_label='Time (s)'

    fig = plt.figure(num=figure_name, figsize=(5,4), dpi=200)
    ax1 = fig.add_subplot(331)
    ax1.yaxis.set_major_formatter(mpl.ticker.ScalarFormatter(useMathText=True, useOffset=True))
    ax1.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax1b = ax1.twinx()
    ax1.plot(time_axis, output['pmf_total'], label='total pmf', zorder=3)
    ax1b.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax1b.fill_between(time_axis,output['light_curve'],0,color=ltc, alpha=.1, zorder=2)
    ax1.set_xlabel(time_label)
    ax1.set_ylabel('pmf (V)')
    ax1b.set_ylim(0, 1.1*np.max(output['light_curve']))
    ax1.set_xlim(0, 1.1*np.max(time_axis))
    ax1b.set_xlim(0, 1.1*np.max(time_axis))
    ax1b.set_ylabel('intensity')
    ax1.yaxis.label.set_color('blue')
    ax1b.yaxis.label.set_color(ltc)
    ax1.spines['left'].set_color('blue')
    ax1b.spines['right'].set_color(ltc)
    ax1b.spines['left'].set_color('blue')
    ax1.tick_params(axis='y', colors='blue')
    ax1b.tick_params(axis='y', colors=ltc)
    ax1.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax1.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 
    ax1b.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax1b.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 
    ax2 = fig.add_subplot(332)
    ax2.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax2b = ax2.twinx()
    ax2.plot(time_axis, output['pHlumen'], label='lumen pH')
    ax2.yaxis.set_major_formatter(FormatStrFormatter('%.1f'))
    ax2.set_xlabel(time_label)
    ax2b.fill_between(time_axis,output['light_curve'],0,color='red', alpha=.1)
    ax2b.set_ylim(0, 1.1*np.max(output['light_curve']))
    ax2b.set_ylabel('intensity')
    ax2.set_ylabel('pH of lumen')
    ax2.set_xlim(0, 1.1*np.max(time_axis))
    ax2b.set_xlim(0, 1.1*np.max(time_axis))
    ax2b.yaxis.set_major_formatter(FormatStrFormatter('%.f'))
    ax2b.set_ylabel('intensity')
    ax2.yaxis.label.set_color('blue')
    ax2b.yaxis.label.set_color(ltc)
    ax2.spines['left'].set_color('blue')
    ax2b.spines['right'].set_color(ltc)
    ax2b.spines['left'].set_color('blue')
    ax2.tick_params(axis='y', colors='blue')
    ax2b.tick_params(axis='y', colors=ltc)
    ax2.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax2.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 
    ax2b.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax2b.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 
    
    ax3 = fig.add_subplot(333)
    ax3.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax3b = ax3.twinx()
    ax3.plot(time_axis, output['Dy'], label='Dy')
    ax3b.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax3.set_xlabel(time_label)
    ax3.set_ylabel(r'$\Delta\psi$ (V)')
    ax3b.fill_between(time_axis,output['light_curve'],0,color='red', alpha=.1)
    ax3b.set_ylim(0, 1.1*np.max(output['light_curve']))
    ax3b.set_ylabel('intensity')
    ax3.set_xlim(0, 1.1*np.max(time_axis))
    ax3b.set_xlim(0, 1.1*np.max(time_axis))
    ax3b.set_ylabel('intensity')
    ax3.yaxis.label.set_color('blue')
    ax3b.yaxis.label.set_color(ltc)
    ax3.spines['left'].set_color('blue')
    ax3b.spines['right'].set_color(ltc)
    ax3b.spines['left'].set_color('blue')
    ax3.tick_params(axis='y', colors='blue')
    ax3b.tick_params(axis='y', colors=ltc)
    ax3.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax3.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 
    ax3b.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax3b.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 
    

    ax4 = fig.add_subplot(334)
    y_formatter = mpl.ticker.ScalarFormatter(useOffset=True)
    ax4.yaxis.set_major_formatter(y_formatter)
    ax4.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax4b = ax4.twinx()
    ax4b.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax4.plot(time_axis, output['Klumen'], label='K+ lumen')
    ax4.set_xlabel(time_label)
    ax4.set_ylabel(r'$K^{+} in lumen$')
    ax4b.fill_between(time_axis,output['light_curve'],0,color='red', alpha=.1)
    ax4b.set_ylim(0, 1.1*np.max(output['light_curve']))
    ax4.set_xlim(0, 1.1*np.max(time_axis))
    ax4b.set_xlim(0, 1.1*np.max(time_axis))
    ax4b.set_ylabel('intensity')
    ax4.yaxis.label.set_color('blue')
    ax4b.yaxis.label.set_color(ltc)
    ax4.spines['left'].set_color('blue')
    ax4b.spines['right'].set_color(ltc)
    ax4b.spines['left'].set_color('blue')
    ax4.tick_params(axis='y', colors='blue')
    ax4b.tick_params(axis='y', colors=ltc)
    ax4.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax4.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 
    ax4b.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax4b.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 

    ax5 = fig.add_subplot(335)
    ax5.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax5b = ax5.twinx()
    ax5b.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax5.plot(time_axis, output['LEF'], color='blue', label='LEF')
    ax5b.plot(time_axis, output['singletO2_rate'], color='red', label='1O2')
    ax5.set_xlabel(time_label)
    ax5.set_ylabel('LEF, ATP')
    ax5b.set_ylabel(r'$^{1}O_2$')
    ax5.set_xlim(0, 1.1*np.max(time_axis))
    ax5b.set_xlim(0, 1.1*np.max(time_axis))
    ax5.tick_params(axis='y', colors='blue')
    ax5b.tick_params(axis='y', colors='red')
    ax5.yaxis.label.set_color('blue')
    ax5b.yaxis.label.set_color('red')
    ax5.spines['left'].set_color('blue')
    ax5b.spines['right'].set_color('red')
    ax5b.spines['left'].set_color('blue')
    ax5.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax5.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 
    ax5b.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax5b.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 

    ax6 = fig.add_subplot(336)
    ax6.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax6b = ax6.twinx()
    ax6.plot(time_axis, output['QAm'], color='blue', label='QA-')
    ax6b.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax6b.plot(time_axis, output['PQH2'], color='green', label='P700_ox')
    ax6.set_xlabel(time_label)
    ax6.set_ylabel(r'$Q_A^{-}$')
    ax6b.set_ylabel(r'$PQH_2$')
    ax6.set_xlim(0, 1.1*np.max(time_axis))
    ax6b.set_xlim(0, 1.1*np.max(time_axis))
    ax6.tick_params(axis='y', colors='blue')
    ax6b.tick_params(axis='y', colors='green')
    ax6.yaxis.label.set_color('blue')
    ax6b.yaxis.label.set_color('green')
    ax6.spines['left'].set_color('blue')
    ax6b.spines['right'].set_color('green')
    ax6b.spines['left'].set_color('blue')
    ax6.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax6.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 
    ax6b.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax6b.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 

    ax7 = fig.add_subplot(337)
    ax7.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax7b = ax7.twinx()
    ax7b.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax7.plot(time_axis, output['Z'], label='Z')
    ax7.plot(time_axis, output['V'], label='V')
    ax7.set_xlabel(time_label)
    ax7.set_ylabel('Z and V')
    ax7b.fill_between(time_axis,output['light_curve'],0,color='red', alpha=.1)
    ax7b.set_ylim(0, 1.1*np.max(output['light_curve']))
    ax7b.set_ylabel('intensity')
    ax7.set_xlim(0, 1.1*np.max(time_axis))
    ax7b.set_xlim(0, 1.1*np.max(time_axis))
    ax7b.set_ylabel('')
    ax7.yaxis.label.set_color('blue')
    ax7b.yaxis.label.set_color(ltc)
    ax7.spines['left'].set_color('blue')
    ax7b.spines['right'].set_color(ltc)
    ax7b.spines['left'].set_color('blue')
    ax7.tick_params(axis='y', colors='blue')
    ax7b.tick_params(axis='y', colors=ltc)
    ax7.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax7.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 
    ax7b.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax7b.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 
    ax7c = ax7.twinx()

    ax7.plot(time_axis, output['V'], label='V')
    ax7c.spines['right'].set_color('orange')
    ax7c.plot(time_axis, output['PsbS_protonated'], label='PsbSH+', color='orange')
    ax7c.set_ylabel('PsbSH+')
    ax7c.yaxis.label.set_color('orange')
            
    ax8 = fig.add_subplot(338)
    ax8.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax8b = ax8.twinx()
    ax8b.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax8.plot(time_axis, output['NPQ'], label='qE')
    ax8.set_xlabel(time_label)
    ax8.set_ylabel('NPQ (qE)')
    ax8b.fill_between(time_axis,output['light_curve'],0,color='red', alpha=.1)
    ax8b.set_ylim(0, 1.1*np.max(output['light_curve']))
    ax8.set_xlim(0, 1.1*np.max(time_axis))
    ax8b.set_xlim(0, 1.1*np.max(time_axis))
    ax8b.set_ylabel('intensity')
    ax8b.set_ylabel('intensity')
    ax8.yaxis.label.set_color('blue')
    ax8b.yaxis.label.set_color(ltc)
    ax8.spines['left'].set_color('blue')
    ax8b.spines['right'].set_color(ltc)
    ax8b.spines['left'].set_color('blue')
    ax8.tick_params(axis='y', colors='blue')
    ax8b.tick_params(axis='y', colors=ltc)
    ax8.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax8.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 
    ax8b.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax8b.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 

    ax9 = fig.add_subplot(339)
    ax9.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax9b = ax9.twinx()
    ax9b.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    ax9.plot(time_axis, output['Phi2'], color='blue', label='Phi2')
    ax9.set_xlabel(time_label)
    ax9.set_ylabel('Phi2')
    ax9b.fill_between(time_axis,output['light_curve'],0,color='red', alpha=.1)
    ax9b.plot(time_axis, output['LEF'], color='red', label='LEF')
    ax9b.set_ylim(0, 1.1*np.max(output['light_curve']))
    ax9.set_xlim(0, 1.1*np.max(time_axis))
    ax9b.set_xlim(0, 1.1*np.max(time_axis))
    ax9b.set_ylabel('intensity (red filled), LEF (blue)')
    ax9.yaxis.label.set_color('blue')
    ax9b.yaxis.label.set_color(ltc)
    ax9.spines['left'].set_color('blue')
    ax9b.spines['right'].set_color(ltc)
    ax9b.spines['left'].set_color('blue')
    ax9.tick_params(axis='y', colors='blue')
    ax9b.tick_params(axis='y', colors=ltc)
    ax9.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax9.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 
    ax9b.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
    ax9b.locator_params(axis = 'y', nbins = 4)# (or axis = 'y') 

    plt.tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
    plt.show()



#                    
#find the global max and min for a list of arrays

def global_min_max(list_of_arrays):
    local_max=[]
    local_min=[]
    for local_array in list_of_arrays:
        local_min.append(np.min(np.array(local_array)))
        local_max.append(np.max(np.array(local_array)))
        #print(local_max)
    global_min=np.min(local_min)
    global_max=np.max(local_max)
    return (global_min,global_max)
                    

def get_axis_limits(ax, scale=.9):
    return ax.get_xlim()[1]*scale, ax.get_ylim()[1]*scale

# plot_gen is a generalized routine for plotting out the kinds of graphs I use
#for the simulation data
# fig = the figure object to which to plot
# sub_plot_number = the subplot number to which to add the plot data
# plot_list is the list of x,y and otehr parameters
# plot_every_nth_point will tell the plotting routine to ony plot a certain
# number of points.
# More details in the code:

def plot_gen(fig, sub_plot_number, plot_list, plot_every_nth_point, **keyword_parameters):
        
    #make three axes, two for data, one for light curve(if needed)
    #all have same x-axis

    any_left=False
    any_right=False
    any_light=False

    for plots in plot_list:
        #print(plots.what_to_plot[1])
        if plots.axis == 'left':
            any_left=True
        if plots.axis == 'right':
            any_right=True
        if plots.axis == 'light':
            any_light=True

    all_axes=[]
    ax1a=fig.add_subplot(sub_plot_number[0], sub_plot_number[1], sub_plot_number[2]) #I assume we have a left axis graph
    
    ax1a.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    all_axes.append(ax1a)
    if any_right: #if we have any right axis graphs, add axis
        ax1b= ax1a.twinx()
        all_axes.append(ax1b)
        ax1b.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
        
    if any_light: #if we have any light axis graphs, add axis
        #print('found light curve')
        ax1c = ax1a.twinx()
        all_axes.append(ax1c)
        ax1c.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
    
    for plots in plot_list: #iterate through all the things we want to plot
        output=plots.output

        #the following makes invisible, the inside facing axes. Only the left-most left 
        #axis and the rigth-most right axis lables will be shown.          
        #say we have a 3 conditions and 2 phenomena. 
        # We want to make the left axes on the leftmost panels to be visible. The left most panels are:
        # 1, 4 
        #which is when sub_plot_number[2]+ sub_plot_number[1]-1 is divisible by the number of conditons, e.g.
        # 1+3-1 = 3 or 4+3-1 =6...
        # I test for this using the modulus function %
        
        
        
        if (sub_plot_number[2]+ sub_plot_number[1]-1)%sub_plot_number[1]==0 and plots.axis=='left': 
            plots.yaxis_visible=True
            
            #next we check for the rightmost panels, noting that in this case, the panel numbers are:
            #3 and #6, both of which are divisible by 3 
            
        elif int(sub_plot_number[2])%int(sub_plot_number[1])==0 and plots.axis=='right':
                plots.yaxis_visible=True
        else:
            # if neither of these conditions are true, we make the axes invisible
            plots.yaxis_visible=False
            plots.show_legend=False  #we only want one copy of the legend. If plots.show_gend is True,
                                     #it will only show for the left most or right-most panels 

        if plots.axis=='left': #use axis ax1a
            ax1=ax1a
            ax1.yaxis.label.set_color(plots.axis_color)
            ax1.spines['left'].set_color(plots.axis_color)
            ax1.tick_params(axis='y', colors=plots.axis_color)
            ax1.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
            ax1.locator_params(axis = 'y', nbins = 6)# (or axis = 'y') 
            plot_font_size=plots.plot_font_size
            #print(plot_font_size)
            ax1.set_xlabel(plots.x_axis_label, fontsize=plot_font_size*1.1)
            ax1.set_ylabel(plots.y_axis_label, fontsize=plot_font_size*1.1, labelpad=2)
            #ax1.set_xlim(0, 1.2*np.max(x_values))
            ax1.ticklabel_format(axis='y', style='sci', scilimits=(-2,2), fontsize=plot_font_size*1.2)

        elif plots.axis=='right':
            ax1=ax1b
            ax1.yaxis.label.set_color(plots.axis_color)
            ax1.spines['right'].set_color(plots.axis_color)
            ax1.tick_params(axis='y', colors=plots.axis_color)
            ax1.locator_params(axis = 'x', nbins = 4)# (or axis = 'y') 
            ax1.locator_params(axis = 'y', nbins = 6)# (or axis = 'y') 
            plot_font_size=plots.plot_font_size
            ax1.set_xlabel(plots.x_axis_label, fontsize=plot_font_size)
            ax1.set_ylabel(plots.y_axis_label, size=plot_font_size*1.2, labelpad=2)
            ax1.ticklabel_format(axis='y', style='sci', scilimits=(-2,2))
            ax1.ticklabel_format(axis='y', style='sci', scilimits=(-2,2), fontsize=plot_font_size*1.2)
            
        elif plots.axis=='light':
            ax1=ax1c
            ax1.spines['right'].set_visible(False)
            ax1.spines['right'].set_visible(False)
            ax1.axes.get_yaxis().set_visible(False)
        
        #detect the bottom row, all others set x-axis invisible
        
        if (sub_plot_number[1] * (sub_plot_number[0]-1)) > sub_plot_number[2]-1:
            ax1.set_xlabel('')
            plt.setp(ax1.get_xticklabels(), visible=False)
        
        x_values=output[plots.what_to_plot[0]][::plot_every_nth_point]

        if plots.subtract_baseline==True:
            y_values= output[plots.what_to_plot[1]]-output[plots.what_to_plot[1]][0]
            y_values=y_values[::plot_every_nth_point]
        else:
            y_values= output[plots.what_to_plot[1]][::plot_every_nth_point]

        ax1.ticklabel_format(useOffset=False)

        if plots.zero_line==True:
            zero_line=[np.min(x_values),np.max(x_values)]
            
            ax1.plot(zero_line,[0,0], linestyle='--', color='grey')

        if plots.axis=='light':
            ax1.fill_between(x_values, y_values,0,color=plots.marker_color, alpha=.1)
        else:
            if plots.linestyle=='solid':                   
                ax1.plot(x_values, y_values, color=plots.marker_color, label=plots.data_label, 
                        lw=plots.linewidth, zorder=3, linestyle=plots.linestyle)
            elif plots.linestyle=='dashed':
                ax1.plot(x_values, y_values, color=plots.marker_color, label=plots.data_label, 
                        lw=plots.linewidth, zorder=3, linestyle=plots.linestyle, dashes=(3, 1))
            else:
                ax1.plot(x_values, y_values, color=plots.marker_color, label=plots.data_label, 
                        lw=plots.linewidth, zorder=3, linestyle=plots.linestyle, dashes=(1, 2))

        if plots.set_maxmin_y==True:
            ax1.set_ylim(plots.maxmin_y[0], plots.maxmin_y[1])  
        else:
            
            ypad=0.1*(np.max(y_values)-np.min(y_values))
            
            ax1.set_ylim(np.min(y_values)-ypad, np.max(y_values)+ypad)  
            
        if plots.set_maxmin_x==True:
            ax1.set_xlim(plots.maxmin_x[0], plots.maxmin_x[1])  
        else:
            ax1.set_xlim(np.min(x_values), np.max(x_values))  
        if plots.axis=='light':
            ax1.set_ylim(0, np.max(y_values))  

        if plots.show_legend==True:
            ax1.legend(loc='upper center', bbox_to_anchor=(0.75, 0.99), fancybox=False, 
                       shadow=False, frameon=False, ncol=1,
                      fontsize=plot_font_size)
        if plots.yaxis_visible==False:
                ax1.axes.get_yaxis().set_visible(False)
        else:
                ax1.axes.get_yaxis().set_visible(True)
        sub_plot_annotation=''
        if ('annotation' in keyword_parameters):
            sub_plot_annotation=keyword_parameters['annotation']
        # place a text box in upper left in axes coords
        props = dict(boxstyle='circle', facecolor='white', alpha=1)
        ax1.text(0.8, .2, sub_plot_annotation, transform=ax1.transAxes, fontsize=plot_font_size,
                    verticalalignment='top', bbox=props)
        ax1.ticklabel_format(axis='y', style='sci', scilimits=(-2,2), fontsize=plot_font_size)
        ax1.tick_params(labelsize=plot_font_size)
    return(all_axes)





def plot_pmf_params(output, use_x_axis, x_axis_label, global_min, global_max):
    sub_base=False
    
    all_min=np.min([global_min['Dy'], global_min['delta_pH_V'],global_min['pmf'] ])
    all_max=np.max([global_max['Dy'], global_max['delta_pH_V'],global_max['pmf'] ])
    
    #set up the left axis of the plot for membrane potential
    what_to_plot=[use_x_axis, 'Dy']
    a1=sim_plot()
    a1.output=output
    a1.what_to_plot=what_to_plot
    a1.data_label=r'$\Delta\psi$'
    a1.axis_color='black'
    a1.marker_color='blue'
    a1.linestyle='solid'
    a1.y_axis_label='potential (V)'
    if x_axis_label != '': 
        a1.x_axis_label=x_axis_label
    else:
        a1.x_axis_label='time (s)'
    a1.axis='left'
    a1.linewidth=1
    a1.subtract_baseline=sub_base
    a1.plot_font_size=7
    a1.zero_line=True
    a1.set_maxmin_y=True
    a1.set_maxmin_x=False
    a1.maxmin_x=[0,1000]
    
    a1.maxmin_y=[all_min, all_max]

    a1.yaxis_visible=True
    a1.show_legend=True

    #add to the left axis, a plot for delta_pH 

    a2=copy.deepcopy(a1) #sim_plot()
    what_to_plot=[use_x_axis, 'delta_pH_V']
    #plot delta pH
    a2.data_label=r'$\Delta$pH'
    a2.axis_color='black'
    a2.marker_color='red'
    a2.what_to_plot=what_to_plot
    a2.linestyle='dashed'
    a2.subtract_baseline=sub_base
    a2.maxmin_y=[all_min, all_max]


    a3=copy.deepcopy(a1)
    what_to_plot=[use_x_axis, 'pmf']
                            
    # add to the left axis, a plot of pmf in V
    a3.what_to_plot=what_to_plot
    a3.data_label='pmf'
    a3.axis_color='black'
    a3.marker_color='green'
    a3.linestyle='solid'
    a3.subtract_baseline=sub_base

    #a3.maxmin_y=[global_min[what_to_plot[1]],global_max[what_to_plot[1]]]
    a3.maxmin_y=[all_min, all_max]



    #set up the right axis of the plot for the llight curve as a semi-transparent filled area, do not discply the axis
    a4=copy.deepcopy(a1)
    what_to_plot=[use_x_axis, 'light_curve']
    a4.axis='light'
    a4.what_to_plot=what_to_plot
    a4.axis_color='red'
    a4.marker_color='red'
    a4.subtract_baseline=False
    a4.set_maxmin_y=False
    #a4.maxmin_y=[global_min[what_to_plot[1]],global_max[what_to_plot[1]]]
    a4.maxmin_y=[all_min, all_max]
    a4.set_maxmin_x=False
    a4.yaxis_visible=False
    a4.maxmin_x=[0,1000]
    
    
    return [a1,a2,a3,a4]

def plot_pmf_params_offset(output, use_x_axis, x_axis_label, global_min, global_max):
    sub_base=False
    
    all_min=np.min([global_min['Dy_offset'], global_min['delta_pH_V_offset'],global_min['pmf_offset'] ])
    all_max=np.max([global_max['Dy_offset'], global_max['delta_pH_V_offset'],global_max['pmf_offset'] ])
    
    #set up the left axis of the plot for membrane potential
    what_to_plot=[use_x_axis, 'Dy_offset']
    a1=sim_plot()
    a1.output=output
    a1.what_to_plot=what_to_plot
    a1.data_label=r'$\Delta\psi$'
    a1.axis_color='black'
    a1.marker_color='blue'
    a1.linestyle='solid'
    a1.y_axis_label=r'$\Delta$ V'
    if x_axis_label != '': 
        a1.x_axis_label=x_axis_label
    else:
        a1.x_axis_label='time (s)'
    a1.axis='left'
    a1.linewidth=1
    a1.subtract_baseline=sub_base
    a1.plot_font_size=7
    a1.zero_line=True
    a1.set_maxmin_y=True
    a1.set_maxmin_x=False
    a1.maxmin_x=[0,1000]
    a1.maxmin_y=[all_min, all_max]
    a1.yaxis_visible=True
    a1.show_legend=True

    #pmf_parameters_plot.append(a1)

    #add to the left axis, a plot for delta_pH 

    a2=copy.deepcopy(a1) #sim_plot()
    what_to_plot=[use_x_axis, 'delta_pH_V_offset']
    #plot delta pH
    a2.data_label=r'$\Delta$pH'
    a2.axis_color='black'
    a2.marker_color='red'
    a2.what_to_plot=what_to_plot
    a2.linestyle='dashed'
    a2.subtract_baseline=sub_base
    a2.maxmin_y=[all_min, all_max]


    a3=copy.deepcopy(a1)
    what_to_plot=[use_x_axis, 'pmf_offset']
                            
    # add to the left axis, a plot of pmf in V
    a3.what_to_plot=what_to_plot
    a3.data_label='pmf'
    a3.axis_color='black'
    a3.marker_color='green'
    a3.linestyle='solid'
    a3.subtract_baseline=sub_base
    a3.maxmin_y=[all_min, all_max]


    #set up the right axis of the plot for the llight curve as a semi-transparent filled area, do not discply the axis
    a4=copy.deepcopy(a1)
    what_to_plot=[use_x_axis, 'light_curve']
    a4.axis='light'
    a4.what_to_plot=what_to_plot
    a4.axis_color='red'
    a4.marker_color='red'
    a4.subtract_baseline=False
    a4.set_maxmin_y=False
    a4.maxmin_y=[all_min, all_max]
    a4.set_maxmin_x=False
    a4.yaxis_visible=False
    a4.maxmin_x=[0,1000]
    return [a1,a2,a3,a4]
    

def plot_K_and_parsing(output, use_x_axis, x_axis_label,global_min, global_max):

    #set up the left axis of the plot for NPQ
    
    a1=sim_plot() #define an instance of the plot 
    what_to_plot=[use_x_axis, 'NPQ'] #indicate thwat to plot. the variable 'use_this_axis' is passed to the function
    
    a1.y_axis_label=r'q$_{E}$' # set the y-axis label
    a1.data_label='qE'
    a1.output=output
    
    a1.what_to_plot=what_to_plot
    a1.axis_color='green'
    a1.marker_color='green'
    a1.linestyle='dashed'
    a1.y_axis_label='NPQ (qE)'
    
    if x_axis_label != '': 
        a1.x_axis_label=x_axis_label #if there is something in x_axis_label then use it.
    else:
        a1.x_axis_label='time (s)'
    a1.axis='left'
    a1.linewidth=1
    a1.subtract_baseline=False
    a1.plot_font_size=7
    a1.zero_line=False
    a1.set_maxmin_y=True
    a1.set_maxmin_x=False
    a1.maxmin_x=[0,1000]
    a1.maxmin_y=[global_min[what_to_plot[1]],global_max[what_to_plot[1]]]
    a1.yaxis_visible=True
    a1.show_legend=False

    #set up the right axis of the plot for [K+]

    a2=copy.deepcopy(a1) #sim_plot()
    what_to_plot=[use_x_axis, 'Klumen']
    a2.data_label=r'lumen $K^{+}$ (M)' #'[K+] lumen (M)'
    a2.axis_color='black'
    a2.marker_color='black'
    a2.what_to_plot=what_to_plot
    a2.linestyle='solid'
    a2.axis='right'
    a2.zero_line=False
    a2.y_axis_label=r'lumen $K^{+}$ (M)' #'[K+] lumen (M)'
    a2.show_legend=False
    a2.set_maxmin_y=True
    #a2.maxmin_y=[global_min[what_to_plot[1]],global_max[what_to_plot[1][1]]]
    a2.maxmin_y=[global_min[what_to_plot[1]],global_max[what_to_plot[1]]]

    #set up the right axis of the plot for the llight curve as a semi-transparent filled area, do not discply the axis
    a4=copy.deepcopy(a1)
    what_to_plot=[use_x_axis, 'light_curve']
    a4.axis='light'
    a4.what_to_plot=what_to_plot
    a4.axis_color='red'
    a4.marker_color='red'
    a4.subtract_baseline=False
    a4.set_maxmin_y=True
    a4.maxmin_y=[global_min[what_to_plot[1]],global_max[what_to_plot[1]]]
    a4.set_maxmin_x=False
    a4.yaxis_visible=False
    a4.maxmin_x=[0,1000]
    a4.show_legend=False
    return [a1,a2,a4]
    

        
def b6f_and_balance(output, use_x_axis, x_axis_label, global_min, global_max):

    #set up the left axis of the plot for NPQ

    a1=sim_plot()
    a1.output=output

    what_to_plot=[use_x_axis, 'b6f_control']
    a1.data_label='rate constant for b6f' #'[K+] lumen (M)'
    a1.axis_color='blue'
    a1.marker_color='blue'
    a1.what_to_plot=what_to_plot
    a1.linestyle='dashed'
    a1.axis='left'
    a1.zero_line=False
    a1.y_axis_label= r'$b_{6}f$ rate constant $(s^{-1})$'  # r'k_{bf}' #'[K+] lumen (M)'  r'$^{1}O_{2}$ $(s^{-1})$ (cumulative)'
    a1.show_legend=False
    a1.set_maxmin_y=True
    a1.maxmin_y=[global_min[what_to_plot[1]],global_max[what_to_plot[1]]]
    a1.set_maxmin_x=False
    a1.yaxis_visible=False
    a1.maxmin_x=[0,1000]
    a1.show_legend=False
    if x_axis_label != '': 
        a1.x_axis_label=x_axis_label
        #print('over riding x_axis label')
    else:
        a1.x_axis_label='time (s)'


    a1.yaxis_visible=True
    a1.show_legend=False
    
    a2=copy.deepcopy(a1) #sim_plot()
    what_to_plot=[use_x_axis, 'pHlumen']
    a2.data_label=r'lumen pH'
    a2.axis_color='red'
    a2.marker_color='red'
    a2.what_to_plot=what_to_plot
    a2.linestyle='solid'
    a2.axis='right'
    a2.zero_line=False
    a2.y_axis_label=r'lumen pH'
    a2.show_legend=False
    a2.set_maxmin_y=True
    a2.maxmin_y=[global_min[what_to_plot[1]],global_max[what_to_plot[1]]]
    
        #set up the right axis of the plot for the llight curve as a semi-transparent filled area, do not discply the axis
    a4=copy.deepcopy(a1)
    what_to_plot=[use_x_axis, 'light_curve']
    a4.axis='light'
    a4.what_to_plot=what_to_plot
    a4.axis_color='red'
    a4.marker_color='red'
    a4.subtract_baseline=False
    a4.set_maxmin_y=True
    a4.maxmin_y=[global_min[what_to_plot[1]],global_max[what_to_plot[1]]]
    a4.set_maxmin_x=False
    a4.yaxis_visible=False
    a4.maxmin_x=[0,1000]
    a4.show_legend=False
    

    return [a1, a2, a4]
    
    
def plot_QAm_and_singletO2(output, use_x_axis, x_axis_label,global_min, global_max):

    #set up the left axis of the plot for NPQ
    a1=sim_plot()
    what_to_plot=[use_x_axis, 'QAm']
    a1.data_label=r'$Q_A^{-}$'
    a1.output=output
    a1.what_to_plot=what_to_plot
    a1.axis_color='green'
    a1.marker_color='green'
    a1.linestyle='dashed'
    a1.y_axis_label=r'$Q_A^{-}$'
    if x_axis_label != '': 
        a1.x_axis_label=x_axis_label
    else:
        a1.x_axis_label='time (s)'
    a1.axis='left'
    a1.linewidth=1
    a1.subtract_baseline=False
    a1.plot_font_size=7
    a1.zero_line=False
    a1.set_maxmin_y=True
    a1.set_maxmin_x=False
    a1.maxmin_x=[0,1000]
    a1.maxmin_y=[global_min[what_to_plot[1]],global_max[what_to_plot[1]]]
    a1.yaxis_visible=True
    a1.show_legend=False

    #set up the right axis of the plot for 1O2

    a2=copy.deepcopy(a1) #sim_plot()
    what_to_plot=[use_x_axis, 'singletO2_rate']
    a2.data_label=r'$^{1}O_{2}$ $(s^{-1})$'
    a2.axis_color='red'
    a2.marker_color='red'
    a2.what_to_plot=what_to_plot
    a2.linestyle='solid'
    a2.axis='right'
    a2.zero_line=False
    a2.y_axis_label=r'$^{1}O_{2} (s^{-1})$'
    a2.show_legend=False
    a2.set_maxmin_y=True
    a2.maxmin_y=[global_min[what_to_plot[1]],global_max[what_to_plot[1]]]

    #set up the right axis of the plot for the llight curve as a semi-transparent filled area, do not discply the axis
    a4=copy.deepcopy(a1)
    what_to_plot=[use_x_axis, 'light_curve']
    a4.axis='light'
    a4.what_to_plot=what_to_plot
    a4.axis_color='red'
    a4.marker_color='red'
    a4.subtract_baseline=False
    a4.set_maxmin_y=True
    a4.maxmin_y=[global_min[what_to_plot[1]],global_max[what_to_plot[1]]]
    a4.set_maxmin_x=False
    a4.yaxis_visible=False
    a4.maxmin_x=[0,1000]
    a4.show_legend=False
    return [a1,a2,a4]
    
def plot_cum_LEF_singetO2(output, use_x_axis, x_axis_label,global_min, global_max):
    #set up the left axis of the plot for commulative LEF
    a1=sim_plot()
    what_to_plot=[use_x_axis, 'LEF_cumulative']
    a1.data_label='LEF cumulative'
    a1.output=output
    
    a1.what_to_plot=what_to_plot
    a1.axis_color='green'
    a1.marker_color='green'
    a1.linestyle='dashed'
    a1.y_axis_label='LEF cumulative'
    if x_axis_label != '': 
        a1.x_axis_label=x_axis_label
    else:
        a1.x_axis_label='time (s)'
    a1.axis='left'
    a1.linewidth=1
    a1.subtract_baseline=False
    a1.plot_font_size=7
    a1.zero_line=False
    a1.set_maxmin_y=True
    a1.set_maxmin_x=False
    a1.maxmin_x=[0,1000]
    #a1.maxmin_y=[global_min[what_to_plot[1]],global_max[what_to_plot[1]]]
    a1.maxmin_y=[0,global_max[what_to_plot[1]]]
    a1.yaxis_visible=True
    a1.show_legend=False

    #set up the right axis of the plot for [K+]
    a2=copy.deepcopy(a1) #sim_plot()
    what_to_plot=[use_x_axis, 'singletO2_array']
    a2.data_label=r'$^{1}O_{2}$ $(s^{-1})$ (cumulative)'
    a2.axis_color='red'
    a2.marker_color='red'
    a2.what_to_plot=what_to_plot
    a2.linestyle='solid'
    a2.axis='right'
    a2.zero_line=False
    a2.y_axis_label=r'$^{1}O_{2}$ (cumulative)'
    a2.show_legend=False
    a2.set_maxmin_y=True
    a2.maxmin_y=[0,global_max[what_to_plot[1]]]
    a2.set_maxmin_x=True
    a2.maxmin_x=[global_min[what_to_plot[0]],global_max[what_to_plot[0]]]

    #set up the right axis of the plot for the llight curve as a semi-transparent filled area, do not discply the axis
    a4=copy.deepcopy(a1)
    what_to_plot=[use_x_axis, 'light_curve']
    a4.axis='light'
    a4.what_to_plot=what_to_plot
    a4.axis_color='red'
    a4.marker_color='red'
    a4.subtract_baseline=False
    a4.set_maxmin_y=True
    a4.maxmin_y=[global_min[what_to_plot[1]],global_max[what_to_plot[1]]]
    a4.set_maxmin_x=False
    a4.set_maxmin_x=True
    a4.maxmin_x=[global_min[what_to_plot[0]],global_max[what_to_plot[0]]]
    a4.show_legend=False

    return [a1,a2,a4]
    
def best_time_scale(output):
    #determine the best time axis to use
    max_time=np.max(output['time_axis'])
    if max_time>3599:    
        use_time_axis='time_axis_h'
        time_label='Time (h)'
    elif max_time>60:
        use_time_axis='time_axis_min'
        time_label='Time (min)'
    else:
        use_time_axis='time_axis'
        time_label='Time (s)'
    return(use_time_axis, time_label)
    
def find_global_max_min(output_list, conditions_to_plot, pad):
    global_min={}
    global_max={}
    rep_output=list(output_list.keys()) #pick the first item on output_list as a representative 

    for k in output_list[rep_output[0]]: #iterate through all the data arrays in output
        gmin_array=[]
        gmax_array=[]
        for condition_name in conditions_to_plot:
            #print(condition_name)
            output=output_list[condition_name]
            gmin_array.append(np.min(output[k]))
            gmax_array.append(np.max(output[k]))
        gmin=np.min(gmin_array)
        gmax=np.max(gmax_array)
        global_min[k]=gmin-(pad*(gmax-gmin))
        global_max[k]=gmax+(pad*(gmax-gmin))
    return(global_min, global_max)
    
#generate a dictionary of plotting functions so they can be more easily called in loops

plot_results={}
plot_results['pmf_params']=plot_pmf_params
plot_results['pmf_params_offset']=plot_pmf_params_offset

plot_results['K_and_parsing']=plot_K_and_parsing
plot_results['plot_QAm_and_singletO2']=plot_QAm_and_singletO2
plot_results['plot_cum_LEF_singetO2']=plot_cum_LEF_singetO2
plot_results['b6f_and_balance'] = b6f_and_balance

def plot_block(output_list, fig, conditions_to_plot, where, phenomena_sets, plot_every_nth_point):
    
    subplot_col_labels=['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
    subplot_row_labels=['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']
    
    #determine the number of colums
    num_cols=len(where)
    num_rows=len(conditions_to_plot)
    number_phenomena_sets=len(phenomena_sets)
    
    global_min, global_max=find_global_max_min(output_list, conditions_to_plot, .1)

    for j, phenomena in enumerate(phenomena_sets):
        for i, condition_name in enumerate(conditions_to_plot):
            output=output_list[condition_name]

            #determine the best time axis (s, min, hours) to use: 
            use_time_axis, time_label=best_time_scale(output)

            #determine the sub_plot_number from number_phenomena_sets, num_rows, j, and where[i]]
            sub_plot_number=[number_phenomena_sets,num_rows,(j*num_rows)+where[i]]
            if j+1==num_rows:
                #print('bottom')
                time_label=''
                
            plot_list=plot_results[phenomena](output, use_time_axis, time_label, global_min, global_max)

            #subplot_annotation_number=j*num_rows+i
            an_text=str(subplot_col_labels[i]) + '.' + subplot_row_labels[j]
            
            plot_gen(fig, sub_plot_number, plot_list, plot_every_nth_point, 
            subplot_label=an_text, annotation=an_text) #subplot_lables[subplot_annotation_number])
            
#shrink will decrease the size of very large data sets by returning every nth point sets

def shrink(output, start_point, take_every_nth_point):
    shrunk={}
    for key in list(output.keys()):
        shrunk[key]=output[key][::take_every_nth_point]
    return(shrunk)


    
class FrozenClass(object):
    __isfrozen = False
    def __setattr__(self, key, value):
        if self.__isfrozen and not hasattr(self, key):
            raise TypeError( "%r is a frozen class" % self )
        object.__setattr__(self, key, value)

    def _freeze(self):
        self.__isfrozen = True

class sim_plot(FrozenClass):
    def __init__(self):
        self.linewidth=1
        self.output={}
        self.data_label=r'$\Delta\psi$'
        self.axis='left'
        self.maxmin=[] #[-1,1]
        self.what_to_plot=['time_axis', 'Dy']
        self.axis_color='blue'
        self.marker_color='blue'
        self.subtract_baseline=False
        self.plot_font_size=7
        self.linestyle='solid'
        self.y_axis_label='y axis'
        self.x_axis_label='x axis'
        self.zero_line=True
        self.set_maxmin_y=True
        self.set_maxmin_x=False
        self.maxmin_x=[0,1000]
        self.maxmin_y=[-.05,.27]
        self.yaxis_visible=True
        self.show_legend=True
        self._freeze() # no new attributes after this point.


        
class States(FrozenClass):
    def __init__(self):
        self.QA_content=1
        self.QAm_content=0.0
        self.PQ_content=6.0
        self.PQH2_content=0.0
        self.Hin=1e-7
        self.pHlumen=7.0
        self.Dy=0.1
        self.pmf=0.18
        self.DeltaGatp=.42
        self.Klumen=.04
        self.Kstroma=.04
        self.PC_ox=0.0
        self.PC_red=2.0
        self.P700_ox=0.0
        self.P700_red=1.0
        self.Z=0.0
        self.V=1.0
        self.NPQ=0.0
        self.singletO2=0
        self.Phi2=0.8
        self.LEF=0.0
        self.Fd_ox=1.0
        self.Fd_red=0.0
        self.ATP_pool=30.0
        self.ADP_pool=30.0
        self.NADPH_pool=0.0
        self.NADP_pool=1.0
        self._freeze() # no new attributes after this point.



#Set up STANDARD initial conditions, most of these values were taken from Cruz et al., 2005
class standard_constants(object):
    #***************************************************************************************
    #paramweters for V-->Z and Z-->V reactions 
    #***************************************************************************************
    VDE_max_turnover_number=1
    pKvde=5.8
    VDE_Hill=4 
    kZE=0.03

    #***************************************************************************************
    #paramweters for PsbS protonation 
    #***************************************************************************************

    pKPsbS=6.4  #pKa for protonation of PsbS, assuming Hill coefficient=1
    max_NPQ=5

    pHstroma_initial=7.8
    #***************************************************************************************
    #paramweters for ATP SYNTHASE
    #***************************************************************************************
    ATP_synthase_content=1
    ATP_synthase_max_turnover=1000*ATP_synthase_content


    #***************************************************************************************
    #Membrane capacitance
    #***************************************************************************************
    Thylakoid_membrane_capacitance = 0.6
    Volts_per_charge=.033 #thylakoid membrane capacitance = 0.6 uF/cmn2

    
    #print('the DGATP is set to: ' + str(DeltaGatp_KJ_per_mol) + ' kJ/mol, which is: ' + str(DeltaGatp_initial) + ' volts')
    #ATP=1/(10**((32-DeltaGatp_initial)/5.7)+1)

    #***************************************************************************************
    # The value of n, calculated from c subunits
    # Here is where we set up the value of n, the ratio of protons/ATP, which I assume is (# of c subunits)/3
    #***************************************************************************************
    
    
    c_subunits_per_ATP_synthase=14
    n=c_subunits_per_ATP_synthase/3 


    #***************************************************************************************
    # Counter ion exchange reactions
    #***************************************************************************************
    #permeability of the thylakoid to K+ 
    perm_K=6000


    #***************************************************************************************
    # b6f reactions
    #***************************************************************************************
    b6f_content=1
    max_b6f=500
    pKreg=6.5
    Em7_PC=0.37
    Em7_PQH2 = 0.11

    #***************************************************************************************
    # Lumen proton bufering reactions
    #***************************************************************************************
    lumen_protons_per_turnover=1.4e-05 #the change in molarity with one H+ transferred to 
    #lumen per PSII
    buffering_capacity=.03

    PSI_antenna_size=1 #setting this to the same valus as PSII_antenna_size will imply that 
                        #equal numbers of photons hit the two photosystems

    k_PC_to_P700=500 #rate constant for oxidation of PC by P700+

    #***************************************************************************************
    # Proton exchange through the KEA3 system
    #***************************************************************************************

    k_KEA=0

    #***************************************************************************************
    #parameters for PSII reactions 
    #***************************************************************************************
    max_PSII=1     
    PSII_antenna_size=1

    kQA=1000  #the rate constant for oxidation of QA- by PQ


    #***************************************************************************************
    #parameters for recombination and singlet O2 production 
    #***************************************************************************************
    k_recomb=0.33
    triplet_yield=.45 #45% of recomnbinations lead to P680 triplets
    triplet_to_singletO2_yield=1 #100% of 3P680 give rise to 1O2


    #***************************************************************************************
    #Light intensity in terms of hits per second to PSII associated antenna 
    #***************************************************************************************

    light_per_L=0

    k_Fd_to_NADP=1000 #rate constant for transfer of electrons from Fd to NADP
    
    k_CBC=3000 #rate constant for the Calvin-Benson cycle
    

#***************************************************************************************
#***************************************************************************************
# Initial concentrations and parameters
#***************************************************************************************
#***************************************************************************************
def DG_to_V(DeltaGatp_KJ_per_mol):
    return(.06*DeltaGatp_KJ_per_mol/5.7)


class standard_initial_states(object):
    V_initial=1
    Z_initial=0
    #start with no ATP made
    ATP_made_initial=0
    PQH2=0
    PQ=6
    PC_ox=0
    PC_red=2
    pmf=0
    pHlumen=7

    Klumen_initial=.04
    Kstroma_initial=.04
    
    #***************************************************************************************
    #DGATP value. The current program will keep this constant
    #***************************************************************************************

    DeltaGatp_KJ_per_mol=42

    #convert DGATP into volts
    DeltaGatp_initial=.06*DeltaGatp_KJ_per_mol/5.7


    #***************************************************************************************
    # Estimate initial pmf
    #***************************************************************************************
    #the initial pmf should be DGATP/N
    n=4.666
    pmf_initial=DeltaGatp_initial/n
    #***************************************************************************************
    #Initial lumen pH
    #the following sets up the initial pmf and pH values
    #pH_stroma will be held constant
    #***************************************************************************************

    pHstroma_initial=7.8
    #pHstroma=pHstroma_initial

    pHlumen_initial=pHstroma_initial-(pmf_initial/.120) #initially, place abouit half of pmf into DpH

    #***************************************************************************************
    #Initial Dy
    #the following sets up the initial Dy
    #***************************************************************************************

    Dy_initial=pmf_initial/2 #place the other half as Dy

    LEF_initial=0
    Phi2_initial=.8


    #print('With n=' + str(n) + ', the pmf at equilibrium with DGATP should be set to : ' + str(pmf_initial))

    #tell the user what the concentration of free H+ is in the lumen
    free_H=10**(-1*pmf_initial)
    #print('the estimated concentration of free protons in the lumen = '  + str(free_H))

    #tell the user the concentration of total protons in the lumen
    buffering_capacity=0.03
    Hin_initial=buffering_capacity*(7-pHlumen)
    #print('the concentration of total (free + bound) protons in the lumen = ' + str(Hin_initial))

    #pHlumen_initial=7-Hin_initial/buffering_capacity
    #print('the initial lumen pH = ' + str(pHlumen_initial))
    QA_content_initial=1
    QAm_content_initial=0

    #***************************************************************************************
    #parameters for PQ pool 
    #***************************************************************************************

    PQH2_content_initial=0
    PQ_content_initial=6

    #***************************************************************************************
    #parameters for Plastocyanin (PC) reactions 
    #***************************************************************************************

    PC_ox_initial = 0
    PC_red_initial= 2

    #***************************************************************************************
    #parameters for P700 reactions 
    #***************************************************************************************

    P700_ox_initial=0
    P700_red_initial=1
    PSI_content=P700_red_initial + P700_ox_initial
    PSI_antenna_size=1 #setting this to the same valus as PSII_antenna_size will imply that 
                        #equal numbers of photons hit the two photosystems


    Fd_ox_initial=1 #currently, Fd will just accumulate 
    Fd_red_initial=0 #currently, Fd will just accumulate 
    

    #***************************************************************************************
    #parameters for NPQ 
    #***************************************************************************************
    NPQ_initial=0

    singletO2_initial=0
    ATP_pool_initial=30
    ADP_pool_initial=30
    NADPH_pool_initial=0
    NADP_pool_initial=1
    
#*******************************************************************************
#*******************************************************************************
#                    Classes to hold constants and states. 
#*******************************************************************************
#********************************************************************************

class sim_constants(FrozenClass):
    def __init__(self):
        S=standard_constants()
        self.pKreg=S.pKreg
        self.max_PSII=S.max_PSII
        self.kQA=S.kQA
        self.max_b6f=S.max_b6f
        self.lumen_protons_per_turnover=S.lumen_protons_per_turnover
        self.light_per_L=S.light_per_L
        self.ATP_synthase_max_turnover=S.ATP_synthase_max_turnover
        self.pHstroma=S.pHstroma_initial
        self.antenna_size=S.PSII_antenna_size
        self.Volts_per_charge=S.Volts_per_charge
        self.perm_K=S.perm_K
        self.n=S.n
        self.Em7_PQH2=S.Em7_PQH2
        self.Em7_PC=S.Em7_PC
        self.PSI_antenna_size=S.PSI_antenna_size
        self.buffering_capacity=S.buffering_capacity
        self.VDE_max_turnover_number=S.VDE_max_turnover_number
        self.pKvde=S.pKvde
        self.VDE_Hill=S.VDE_Hill
        self.kZE=S.kZE
        self.pKPsbS=S.pKPsbS
        self.max_NPQ=S.max_NPQ
        self.k_recomb=S.k_recomb
        self.k_PC_to_P700=S.k_PC_to_P700
        self.triplet_yield=S.triplet_yield
        self.triplet_to_singletO2_yield=S.triplet_to_singletO2_yield
        self.fraction_pH_effect=0.25
        self.k_Fd_to_NADP=5000
        self.k_CBC=3000
        self.k_KEA=100
        
    def as_tuple(self):
        c=(self.pKreg, self.max_PSII, self.kQA, self.max_b6f, self.lumen_protons_per_turnover, self.light_per_L,
        self.ATP_synthase_max_turnover,self.pHstroma, self.antenna_size, self.Volts_per_charge, self.perm_K,
        self.n, self.Em7_PQH2, self.Em7_PC, self.PSI_antenna_size, self.buffering_capacity, 
        self.VDE_max_turnover_number, self.pKvde, self.VDE_Hill, self.kZE, self.pKPsbS, self.max_NPQ, 
        self.k_recomb, self.k_PC_to_P700, self.triplet_yield, self.triplet_to_singletO2_yield, 
        self.fraction_pH_effect, self.k_Fd_to_NADP, self.k_CBC, self.k_KEA)
        return(c)
    
    def as_dictionary(self):
        
        d={'pKreg':self.pKreg, 'max_PSII':self.max_PSII,'kQA': self.kQA, 'max_b6f': self.max_b6f, 
        'lumen_protons_per_turnover': self.lumen_protons_per_turnover, 'light_per_L':self.light_per_L,
        'ATP_synthase_max_turnover': self.ATP_synthase_max_turnover, 'pHstroma': self.pHstroma, 
        'antenna_size': self.antenna_size, 'Volts_per_chargese': self.Volts_per_charge, 
        'perm_K': self.perm_K, 'n': self.n, 'Em7_PQH2': self.Em7_PQH2, 'Em7_PC': self.Em7_PC, 
        'PSI_antenna_size': self.PSI_antenna_size, 'buffering_capacity': self.buffering_capacity, 
        'VDE_max_turnover_number': self.VDE_max_turnover_number, 'pKvde': self.pKvde, 'VDE_Hill': self.VDE_Hill, 
        'kZE': self.kZE, 'pKPsbS': self.pKPsbS, 'max_NPQ': self.max_NPQ, 
        'k_recomb': self.k_recomb, 'k_PC_to_P700': self.k_PC_to_P700, 'triplet_yield': self.triplet_yield, 
        'triplet_to_singletO2_yield': self.triplet_to_singletO2_yield, 'fraction_pH_effect': self.fraction_pH_effect, 
        "k_Fd_to_NADP":self.k_Fd_to_NADP, "k_CBC": self.k_CBC, "k_KEA":self.k_KEA}
        return(d)
        
    def short_descriptions(self):
        e={'pKreg':'The regulatory pKa at which the cytochrome b6f complex is slowed by lumen pH', 
        'max_PSII':'The maximum relative rate of PSII centers (0-1)',
        'kQA': 'The averate rate constant of oxidation of QA- by QB and PQ', 
        'max_b6f': 'The maximum turnover rate for oxidation of PQH2 by the b6f complex at high pH', 
        'lumen_protons_per_turnover': 'The molarity change of protons resulting from 1 H+/standard PSII into the lumen', 
        'light_per_L':'PAR photons per PSII',
        'ATP_synthase_max_turnover': 'Defines the slope of ATP synthesis per pmf', 
        'pHstroma': 'The pH of the stroma', 
        'antenna_size': 'The relative antenna size of PSII', 
        'Volts_per_chargese': 'The capcitance of the thylakoid expressed as V/charge/PSII', 
        'perm_K': 'The relative permeability of the thylakoid to counterions', 
        'n': 'The stoichiometry of H+/ATP at the ATP synthase', 
        'Em7_PQH2': 'The midpoint potential of the PQ/PQH2 couple at pH=7', 
        'Em7_PC': 'The midpoint potential of the plastocyanin couple at pH=7', 
        'PSI_antenna_size': 'The relative cross section of PSI antenna', 
        'buffering_capacity': 'The proton buffering capacity of the lumen in M/pH unit', 
        'VDE_max_turnover_number': 'The maximal turnover of the fully protonated VDE enzyme', 
        'pKvde': 'The pKa for protonation and activation of VDE', 
        'VDE_Hill': 'The Hill coefficient for protonation of VDE', 
        'kZE': 'The rate constant for ZE (zeaxanthin epoxidase', 
        'pKPsbS': 'The pKa for protonation and activation of PsbS', 
        'max_NPQ': 'NPQ=(nax_NPQ)(PsbS protonation)(Z)', 
        'k_recomb': 'The average recombination rate for S2QA- and S3QA- with no detla.psi (s-1)', 
        'k_PC_to_P700': 'The rate constant for transfer of electrons from PC to P700+',
        'triplet_yield': 'The yield of triplets from each recombination event', 
        'triplet_to_singletO2_yield': 'The yield of 1O2 for each triplet formed', 
        'fraction_pH_effect': 'The frqaction of S-states that both involve protons release and can reconbine', 
        "k_Fd_to_NADP":'The second order rate constant for oxidation of Fd by NADP+', 
        "k_CBC": 'The rate constant for a simplified Calvin-Benson Cycle',
        "k_KEA": 'The rate constant for the KEA H+/H+ antiporter'}
        return(e)
        
        #self._freeze() # no new attributes after this point.
        
        
class sim_states(FrozenClass):
    def __init__(self):
        S=standard_initial_states()
        self.QA_content=S.QA_content_initial
        self.QAm_content=S.QAm_content_initial
        self.PQ_content=S.PQ_content_initial
        self.PQH2_content=S.PQH2_content_initial
        self.Hin=S.Hin_initial
        self.pHlumen=S.pHlumen_initial
        self.Dy=S.Dy_initial
        self.pmf=S.pmf_initial
        self.DeltaGatp=S.DeltaGatp_initial
        self.Klumen=S.Klumen_initial
        self.Kstroma=S.Kstroma_initial
        self.ATP_made=S.ATP_made_initial
        self.PC_ox=S.PC_ox_initial
        self.PC_red=S.PC_red_initial
        self.P700_ox=S.P700_ox_initial
        self.P700_red=S.P700_red_initial
        self.Z=S.Z_initial
        self.V=S.V_initial
        self.NPQ=S.NPQ_initial
        self.singletO2=S.singletO2_initial
        self.Phi2=S.Phi2_initial
        self.LEF=S.LEF_initial
        self.Fd_ox=S.Fd_ox_initial
        self.Fd_red=S.Fd_red_initial
        self.ATP_pool=S.ATP_pool_initial
        self.ADP_pool=S.ADP_pool_initial
        self.NADPH_pool=S.NADPH_pool_initial
        self.NADP_pool=S.NADP_pool_initial
        
    def as_list(self):
            t=[self.QA_content, self.QAm_content, self.PQ_content, 
                       self.PQH2_content, self.Hin, self.pHlumen, self.Dy, self.pmf, self.DeltaGatp,
                       self.Klumen, self.Kstroma, self.ATP_made, self.PC_ox, 
                       self.PC_red, self.P700_ox, self.P700_red, self.Z,self.V, self.NPQ,
                       self.singletO2, self.Phi2, self.LEF, self.Fd_ox, self.Fd_red, self.ATP_pool, 
                       self.ADP_pool, self.NADPH_pool, self.NADP_pool]
            return(t)
        
    def as_tuple(self):
            t=tuple([self.QA_content, self.QAm_content, self.PQ_content, 
                       self.PQH2_content, self.Hin, self.pHlumen, self.Dy, self.pmf, self.DeltaGatp,
                       self.Klumen, self.Kstroma, self.ATP_made, self.PC_ox, 
                       self.PC_red, self.P700_ox, self.P700_red, self.Z,self.V, self.NPQ,
                       self.singletO2, self.Phi2, self.LEF, self.Fd_ox, self.Fd_red, self.ATP_pool, 
                       self.ADP_pool, self.NADPH_pool, self.NADP_pool])
            return(t)
        

    def load_from_tupple(self, Y):
        self.QA_content=Y[0]
        self.QAm_content=Y[1]
        self.PQ_content=Y[2] 
        self.PQH2_content=Y[3]
        self.Hin=Y[4]
        self.pHlumen=Y[5]
        self.Dy=Y[6]
        self.pmf=Y[7]
        self.DeltaGatp=Y[8]
        self.Klumen=Y[9]
        self.Kstroma=Y[10]
        self.ATP_made=Y[11]
        self.PC_ox=Y[12]
        self.PC_red=Y[13]
        self.P700_ox=Y[14]
        self.P700_red=Y[15]
        self.Z=Y[16]
        self.V=Y[17]
        self.NPQ=Y[18]
        self.singletO2=Y[19]
        self.Phi2=Y[20]
        self.LEF=Y[21]
        self.Fd_ox=Y[22]
        self.Fd_red=Y[23]
        self.ATP_pool=Y[24]
        self.ADP_pool=Y[25]
        self.NADPH_pool=Y[26]
        self.NADP_pool=Y[27]
    
    def as_dictionary(self):
        d={'QA_content': self.QA_content,
        'QAm_content':self.QAm_content,
        'PQ_content':self.PQ_content,
        'PQH2_content': self.PQH2_content,
        'Hin':self.Hin,
        'pHlumen': self.pHlumen,
        'Dy':self.Dy,
        'pmf':self.pmf,
        'DeltaGatp': self.DeltaGatp,
        'Klumen':self.Klumen,
        'Kstroma': self.Kstroma,
        'ATP_made': self.ATP_made,
        'PC_ox': self.PC_ox,
        'PC_red': self.PC_red,
        'P700_ox':self.P700_ox,
        'P700_red': self.P700_red,
        'Z':self.Z,
        'V':self.V,
        'NPQ':self.NPQ,
        'singletO2':self.singletO2,
        'Phi2':self.Phi2,
        'LEF': self.LEF,
        'Fd_ox': self.Fd_ox,
        'Fd_red': self.Fd_red,
        'ATP_pool': self.ATP_pool,
        'ADP_pool':self.ADP_pool,
        'NADPH_pool': self.NADPH_pool,
        'NADP_pool':self.NADP_pool}
        self._freeze() # no new attributes after this point.
        return(d)

    
#*******************************************************************************
#*******************************************************************************
#                    Display notes, states and constants. 
#*******************************************************************************
#********************************************************************************


class ListTable(list):
    """ Overridden list class which takes a 2-dimensional list of 
        the form [[1,2,3],[4,5,6]], and renders an HTML Table in 
        IPython Notebook. """
    
    def _repr_html_(self):
        html = ["<table>"]
        for row in self:
            html.append("<tr>")
            
            for col in row:
                html.append("<td>{0}</td>".format(col))
            
            html.append("</tr>")
        html.append("</table>")
        return ''.join(html)
        
#Display all constants in a table
def All_Constants_Table(table_title, Kxx):
    table = ListTable()
    table.append(['Parameter', 'New Value']) #, 'Short Description'])
    #Kxx=sim_constants()
    Kdict=Kxx.as_dictionary()
    #Ksumm=Kxx.short_descriptions()

    for key in list(Kdict.keys()):

        table.append([key, Kdict[key]]) #, Ksumm[key]])
    print(table_title)
    display(table)
    
#display only the constants that are different
def Changed_Constants_Table(table_title, original_values, Kxx):
    table = ListTable()
    table.append(['Changed Parameter', 'Old Value', 'New Value']) #, 'Short Description'])
    Kdict=Kxx.as_dictionary()
    #Ksumm=Kxx.short_descriptions()
    #temp=sim_constants()
    original_values_dict=original_values.as_dictionary()

    for key in list(Kdict.keys()):
        if Kdict[key] == original_values_dict[key]:
            pass
        else:
            table.append([key, original_values_dict[key], Kdict[key]]) #, Ksumm[key]])
    print(table_title)
    display(table)



#Display PDFs of the detailed notes describing the simulation parameters
def display_detailed_notes():
    from IPython.display import IFrame
    from IPython.display import Image

    page1=Image(PDF_file_location + 'Page 1.png')
    page2=Image(PDF_file_location + 'Page 2.png')
    page3=Image(PDF_file_location + 'Page 3.png')

    display(page1)
    display(page2)
    display(page3)
    
    
#*******************************************************************************
#*******************************************************************************
#                    Startup code to get things set up. 
#*******************************************************************************
#********************************************************************************


#run the code to make all pre-contrived light waves
light_pattern=make_waves()

#The following code generates a series of diurnal light patters, with either smooth or fluctuating
#patterns

#### Simple Sin Wave Envelope####
#Start with the generation of a general envelope (in this case a sine wave)
day_length=10 # THe day length in hours
max_PAR=300 #the maximum PAR at mid-day
envelope=sin_light(day_length, max_PAR, 10) #make an envelope shaped like a sin wave

fluctuations={} #Set up the 'fluctuations dictionary
fluctuations['type']='none' #in this case, do not add any fluctuations ('type' = 'none')
light_list=[] #generate a list to contain the light pattern
light_array=generate_light_profile(envelope, fluctuations) # Put is all together to generate the light profile
light_list.append(light_array) #append this pattern onto a list

#the following REMed code shows how to plot out the light patterns, if desired
#plt.plot(light_array[0], light_array[1]) 

#### Sin Wave with rapid (on average, 100 s duration) Random Square fluctuations ####

fluctuations={}
fluctuations['type']='square' #defines the shape of the fluctuations
fluctuations['distribution']='random' #make the TIME distribution random
fluctuations['tao']=100 #tao gives the time range over which the random fluctuations occur
fluctuations['variations']='random' #This sets the amplitudes of the fluctuations to random
fluctuations['amplitude']=[-.8,0.8] #the maximal fractional changes, relative to the envelope
                                    #for the fluctuations. In this case they can range from 0.2
                                    #to 1.8 of the envelop (i.e. envelope_value+(envelope_value * -0.8) 
                                    # to 1 + envelope_value+(envelope_value * 0.8) 
fluctuations['begin']='1' #start time for the fluctuations
fluctuations['end']='9' #end time for the fluctuations
fluctuations['smooth_points']='40'  #after making the fluctuations, smooth the resulting curve using
                                    #a boxcar algorithm to prevent the transitions from being too sharp
light_array_1=generate_light_profile(envelope, fluctuations) #make the array of time and light values
light_list.append(light_array_1) #append to the light_list 

#plt.plot(light_array[0], light_array[1]) 

#### Sin Wave with rapid (on average, 300 s duration) Random Square fluctuations ####
#repeat the above, but with LOWER frequency changes
fluctuations={}
fluctuations['type']='square'
fluctuations['distribution']='random'
fluctuations['tao']=300
fluctuations['variations']='random'
fluctuations['amplitude']=[-0.8,.8] #the maximal fractional change 
fluctuations['begin']='1'
fluctuations['end']='9'
fluctuations['smooth_points']='40'
light_array_2=generate_light_profile(envelope, fluctuations)
light_list.append(light_array_2)

#### Sin Wave with rapid (on average, 1000 s duration) Random Square fluctuations ####
#repeat the above, but with VERY LOW frequency changes

#plt.plot(light_array[0], light_array[1]) 
fluctuations={}
fluctuations['type']='square'
fluctuations['distribution']='random'
fluctuations['tao']=1000
fluctuations['variations']='random'
fluctuations['amplitude']=[-0.8,.8] #the maximal fractional change 
fluctuations['begin']='1'
fluctuations['end']='9'
fluctuations['smooth_points']='40'

light_array_3=generate_light_profile(envelope, fluctuations)

light_list.append(light_array_3)

#The following REMed code plots out all the fluctuation patterns
#fig=plt.figure()
#ax1=fig.add_subplot(131)
#ax1.set_title('light_array_1')
#ax1.plot(light_array_1[0], light_array_1[1]) 
#ax2=fig.add_subplot(132)
#ax2.set_title('light_array_2')
#ax2.plot(light_array_2[0], light_array_2[1]) 
#ax3=fig.add_subplot(133)
#ax3.set_title('light_array_3')
#ax3.plot(light_array_3[0], light_array_3[1]) 
#plt.tight_layout()
#plt.show()


