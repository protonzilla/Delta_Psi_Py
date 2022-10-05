

#*******************************************************************************
#*******************************************************************************
#                   Code related to generating light curves                    *
#*******************************************************************************
#*******************************************************************************

import numpy as np
from scipy import integrate
from scipy import signal

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
    test_times_array=np.linspace(0.0, int(total_duration_in_seconds), int(test_number_points), dtype=float)

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
    baseline_time=np.linspace(0.0, int(baseline_duration), int(baseline_points))
    baseline_intensity_array=np.linspace(int(baseline_intensity), int(baseline_intensity),int(baseline_points))
    pulse_times=np.append(pulse_times, baseline_time)
    pulse_light=np.append(pulse_light, baseline_intensity_array)

    riser_duration=rise_time*time_div
    riser_points=riser_duration*point_frequency
    riser_start_time = (baseline_points+1) / point_frequency
    riser_end_time = riser_start_time + riser_duration
    riser_time=np.linspace(int(riser_start_time), int(riser_end_time), int(riser_points))
    riser_light=np.linspace(int(baseline_intensity), int(pulse_intensity), int(riser_points))
    
    pulse_times=np.append(pulse_times, riser_time)
    pulse_light=np.append(pulse_light, riser_light)
    pulse_duration=pulse_duration*time_div
    pulse_points=pulse_duration*point_frequency
    pulse_start_time = (baseline_points + riser_points +1)/point_frequency
    pulse_end_time = pulse_start_time + pulse_duration
    pulse_time=np.linspace(int(pulse_start_time), int(pulse_end_time), int(pulse_points))
    pulse_light_array=np.linspace(int(pulse_intensity), int(pulse_intensity), int(pulse_points))
    pulse_times=np.append(pulse_times, pulse_time)
    pulse_light=np.append(pulse_light, pulse_light_array)
    
    falling_duration=rise_time*time_div
    falling_points=riser_duration*point_frequency
    falling_start_time = (baseline_points + riser_points + pulse_points + 1) / point_frequency
    falling_end_time = falling_start_time + falling_duration
    falling_time=np.linspace(int(falling_start_time), int(falling_end_time), int(falling_points))
    falling_light=np.linspace(int(pulse_intensity), int(recovery_intensity), int(falling_points))
    
    pulse_times=np.append(pulse_times, falling_time)
    pulse_light=np.append(pulse_light, falling_light)
    
    recovery_duration=recovery_duration*time_div
    recovery_points=recovery_duration*point_frequency
    recovery_start_time = (baseline_points + riser_points + pulse_points + falling_points + 1) / point_frequency
    recovery_end_time = recovery_start_time + recovery_duration
    recovery_time=np.linspace(int(recovery_start_time), int(recovery_end_time), int(recovery_points))
    recovery_light=np.linspace(int(recovery_intensity), int(recovery_intensity), int(recovery_points))

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
    baseline_time=np.linspace(0.0, int(baseline_duration), int(baseline_points)) #generate the baseline array, starting at zero
    baseline_intensity_array= np.linspace(int(baseline_intensity), int(baseline_intensity),int(baseline_points)) #fill baseline array with baseline light intensity

    pulse_times=np.append(pulse_times, baseline_time) 
    pulse_light=np.append(pulse_light, baseline_intensity_array)

    riser_duration=rise_time*time_div
    riser_points=riser_duration*point_frequency
    riser_start_time = (baseline_points+1) / point_frequency
    
    riser_end_time = riser_start_time + riser_duration
    riser_time=np.linspace(int(riser_start_time), int(riser_end_time), int(riser_points))
    riser_light=np.linspace(int(baseline_intensity), int(pulse_intensity), int(riser_points))
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


    pulse_time=np.linspace(int(pulse_start_time), int(pulse_end_time), int(pulse_points))
    pulse_light_array=np.linspace(int(pulse_intensity), int(pulse_intensity), int(pulse_points))
    pulse_times=np.append(pulse_times, pulse_time)
    pulse_light=np.append(pulse_light, pulse_light_array)
    
    falling_duration=rise_time*time_div
    falling_points=riser_duration*point_frequency
    
    #falling_start_time = (baseline_points + riser_points + pulse_points + 1) / point_frequency
    falling_start_time = pulse_times[-1] + 1/point_frequency

    falling_end_time = falling_start_time + falling_duration
    
    #print('fst= ' + str(falling_start_time))
    #print('fet= ' + str(falling_end_time))


    falling_time=np.linspace(int(falling_start_time), int(falling_end_time), int(falling_points))
    falling_light=np.linspace(int(pulse_intensity), int(recovery_intensity), int(falling_points))
    
    pulse_times=np.append(pulse_times, falling_time)
    pulse_light=np.append(pulse_light, falling_light)
    
    recovery_duration=recovery_duration*time_div
    recovery_points=recovery_duration*point_frequency
    recovery_start_time = pulse_times[-1] + 1/point_frequency
    recovery_end_time = recovery_start_time + recovery_duration
    

    recovery_time=np.linspace(int(recovery_start_time), int(recovery_end_time), int(recovery_points))
    recovery_light=np.linspace(int(recovery_intensity), int(recovery_intensity), int(recovery_points))

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
    time_axis_s=np.linspace(0.0,int(day_length_s), int(day_length_s*points_per_second))
    flat_envelope=np.linspace(int(PAR),int(PAR), int(day_length_s*points_per_second))
    return(time_axis_s, flat_envelope)

def sin_light(day_length, max_PAR, points_per_second): 
    
    day_length_s=day_length*60*60
    time_axis_s = np.linspace(0.0, int(day_length_s), int(day_length_s*points_per_second), endpoint=False)
    #generate the envelope trace
    envelope=signal.cosine(day_length_s*points_per_second)*max_PAR
    return([time_axis_s, envelope])


def generate_light_profile(input_envelope, fluctuations): 
    time_axis_s=input_envelope[0]
    day_length_s=time_axis_s[-1]
    points_per_second=len(time_axis_s)/day_length_s
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
                    light_fluct=np.append(light_fluct, np.linspace(int(fluctuation_amplitude), int(fluctuation_amplitude), int((duration_of_fluctuation*points_per_second))))
                    light_array=np.append(light_array, np.linspace(int(light_value), int(light_value), int((duration_of_fluctuation*points_per_second))))

                else:
                    light_fluct=np.append(light_fluct, np.linspace(0.0, 0.0, int((duration_of_fluctuation*points_per_second))))
                    light_array=np.append(light_array, envelope[time_index:time_index+int(duration_of_fluctuation*points_per_second)])

                    #light_value = envelope[len(light_fluct)]


                time_index=time_index+int(duration_of_fluctuation*points_per_second)
            light_array_smoothed=smooth(light_array, int(fluctuations['smooth_points']))
            out_put_light_array=light_array_smoothed[0:len(time_axis_s)]
    else:
        out_put_light_array=envelope
        
    return([time_axis_s, out_put_light_array])


def generate_sin_wave(total_duration, max_PAR, light_frequency, points_per_second):
    test_number_points=total_duration*points_per_second
    times_array=np.linspace(0.0, int(total_duration), int(test_number_points), dtype=float)
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
