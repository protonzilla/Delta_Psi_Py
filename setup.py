from setuptools import setup, find_packages
setup(
    name = "Delta_Psi_Py",
    version = "1.0",
    packages = ['delta_psi_py'],
    test_suite = 'tests',

    # Project uses reStructuredText, so ensure that the docutils get
    # installed or upgraded on the target machine
    install_requires = ['numpy','pandas','scipy','matplotlib'],

    #package_data = {
    #    # If any package contains *.txt or *.rst files, include them:
    #    '': ['*.txt', '*.rst'],
    #    # And include any *.msg files found in the 'hello' package, too:
    #    'hello': ['*.msg'],
    #},

    # could also include long_description, download_url, classifiers, etc.
)
