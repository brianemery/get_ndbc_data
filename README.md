# get_ndbc_data

A very simple tool for retrieving data from the NDBC web site. May eventually be a location for several similar tools. For now this includes get_ndbc_archive_data.m for retrieving wind data. 

    % EXAMPLE
    NDBC = get_ndbc_archive_data( datenum([2019 2020],[1 12],[1 31]) ,'46054');

This code will work within a narrow range of input options but can be easily modified

Brian Emery, May 2021
