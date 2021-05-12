function NDBC = get_ndbc_archive_data(st,buoy)
% GET NDBC ARCIVE DATA - download wind data from the NDBC
%
% Useful for getting data that is more than 45 days old
% eg from https://www.ndbc.noaa.gov/view_text_file.php?filename=46054h2017.txt.gz&dir=data/historical/stdmet/
%
%  ... more t
% ... a bit of a work in progress, much simpler than all the old ones ...
%
% EXAMPLE
% NDBC = get_ndbc_archive_data( datenum([2019 2020],[1 12],[1 31]) ,'46054');
% 
%
% SEE ALSO
% getNDBCwindDataFromWeb.m (obsolete) 

% 15 April 2021 Brian M Emery
%   from other bits and pieces

% TO DO
% - multiple buoy's 
% - parse outputs by date range
% - more robust to errors in the time ranges ...
% 
% Also, multiple buoys could be output in a single struct with rows corresponding
% to location, you know.


% deal with option of only inputting end points for times
if length(st)==2
    st=st(1):(1/24):st(2); disp('assumed hourly data requested')
end

% % user setting:
% if nargin<2
%     buoy={'46054';'46062';'46011';'46023';'46053';};%;
% end
% 
% % %% %% %% %
% ndbc_loc

% create the cell array of years
year = unique(cellstr(datestr(st,10)));

% url = 'https://www.ndbc.noaa.gov/view_text_file.php?filename=46054h2017.txt.gz&dir=data/historical/stdmet/';
site_url = 'https://www.ndbc.noaa.gov/view_text_file.php?filename=';

% for i = 1:numel(buoy)
    for j=1:length(year)

        % Run this on the url specifying year, then as one of the catches,
        % run in on another url to try to find the monthly data
        url = [site_url buoy 'h' year{j} '.txt.gz&dir=data/historical/stdmet/'];

        disp(['Trying to get data for ' buoy ' ' year{j}])
         NDBC(j) = retrieve_data(url,buoy);
        
    end
% end

NDBC=struct_cat(1,NDBC); % need to clean up units

end

function NDBC = retrieve_data(url,buoy)
% MAIN ENGINE

% Pre allocate NDBC struct to allow empty outputs when errors encountered?
NDBC(1).BuoyName = buoy;
NDBC.Url = {url};


% this has no newline character
%try
    S = webread(url);
% catch
%     disp('error with webread, check that url is valid')
%     S =[];
% end

% 18 columns of numbers, 2 headers lines
C = textscan(S,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','Headerlines',2);

% get header and units too
Hdr = textscan(S,'%s',18); Hdr = Hdr{1};
Units = textscan(S,'%s',18,'Headerlines',1); Units = Units{1};

% remove #
Hdr{1} = regexprep(Hdr{1},'#','');
Units{1} = regexprep(Units{1},'#','');

% now paste it all together
NDBC.TimeStamp = datenum(C{1},C{2},C{3},C{4},C{5},0);

for i = 6:numel(Hdr)
   
    NDBC.(Hdr{i}) = C{i};
    
end

% convert the wind (the 'from' directions in cwN) to U and V <-VERIFY THIS?
[NDBC.U,NDBC.V] = speeddir2uv(-NDBC.WSPD,cwN2ccwE(NDBC.WDIR));

% 99 removals    
%     idx=find(wd==999); wd(idx)=NaN; clear idx
%     idx=find(wspd==99); wspd(idx)=NaN; clear idx
%  idx=find(wvht==99); wvht(idx)=NaN*ones(size(idx)); clear idx
%     idx=find(wvdpd==99); wvdpd(idx)=NaN*ones(size(idx)); clear idx

NDBC.Units = Units; 
NDBC.CreateTimeStamp = datestr(now);
NDBC.ProcessingSteps{1} = mfilename; 


NDBC.WSPD(NDBC.WSPD==99) = NaN;



% 
%                      Type: 'Ideal'
%                  SiteName: ''
%                  SiteCode: 1
%                SiteOrigin: [NaN NaN]
%                  FileName: {1×0 cell}
%                 TimeStamp: [1×0 double]
%                  TimeZone: 'GMT'
%                    LonLat: [0×2 double]
%             RangeBearHead: [0×3 double]
%                   RadComp: []
%                     Error: []
%                      Flag: []
%                         U: []
%                         V: []
%               LonLatUnits: {'Decimal Degrees'  'Decimal Degrees'}
%        RangeBearHeadUnits: {'km'  'Degrees_ccw_from_east'  'Degrees_ccw_from_east'}
%              RadCompUnits: 'cm/s'
%                ErrorUnits: 'cm/s'
%                    UUnits: 'cm/s'
%                    VUnits: 'cm/s'
%           CreateTimeStamp: '15-Apr-2021 17:54:44'
%            CreateTimeZone: 'GMT'
%           OtherMatrixVars: [1×1 struct]
%             OtherMetadata: [0×0 struct]
%           ProcessingSteps: {}
%     RADIAL_struct_version: '/m_files/tools/codar/my_hfrp_tools/RADIALstruct.m'
% 

end


function ndbc_loc
% Station 46062 - Pt. San Luis, CA - 18 NM South Southwest of Morro Bay, CA.
ndbc62_loc=[-121.01 35.10]; % N  W (35°06'03"N 121°00'36" W)

% 34°52'51"N 120°52'10" W
ndbc11_loc=[-120-(52./60)-(10./3600) 34+(52/60)+(51/3600)];

% 34°42'50"N 120°58'00"W
ndbc23_loc=[-120-(58./60)-(00./3600) 34+(42/60)+(50/3600)];

% Station 46063 - Pt.Conception, CA - 50NM West of Santa Barbara, CA.
% 34.25 N 120.66 W (34°15'03"N 120°39'53" W)

% 34°16'08"N 120°26'54" W
ndbc54_loc=[-120-(26./60)-(54./3600) 34+(16/60)+(08/3600)];

% 34°14'10"N 119°51'00"W
ndbc53_loc=[-119-(51./60)-(00./3600) 34+(14/60)+(10/3600)];

% 34°16'35"N 120°39'53" W)
ndbc63_loc=[-120-(39./60)-(53./3600) 34+(16/60)+(35/3600)];



end


function old_way

% TO DO
% solve this problem:
% 
% [status,txt] = system('curl -o tmp.zip.gz https://www.ndbc.noaa.gov/view_text_file.php?filename=46053h2012.txt.gz&dir=data/historical/stdmet/');
% txt
% 
% txt =
% 
%     'Unable to access 46053h2012.txt.gz
%      '
%
% 99, 999, and 9999 remova?


fid = fopen(file,'rt');

% get header as cell array
hdr = strsplit(regexprep(fgetl(fid),'#','')); 

% same for units
units = strsplit(regexprep(fgetl(fid),'#',''));  

dat = NaN(1,length(units));

i = 1;

while 1
     str = fgetl(fid);

     if str == -1
        break
     end
     
     dat(i,:) = str2num(str); i= i+1;
     

end
fclose(fid);



% PACK IT UP IN A STRUCT

fn = hdr;

ndbc.TimeStamp = [];
ndbc.Buoy = [];
ndbc.FileName = file;
ndbc.Units = [];

% do it this way to prevent offset mess ups
for i = 1:numel(fn)
    
    ndbc.(fn{i}) = dat(:,i);
    ndbc.Units.(fn{i}) = units{i};
    
end


% times
ndbc.TimeStamp = datenum(ndbc.YY,ndbc.MM,ndbc.DD,ndbc.hh,ndbc.mm,0);

% convert the wind (the 'from' directions in cwN) to U and V
[ndbc.U,ndbc.V] = speeddir2uv(-ndbc.WSPD,cwN2ccwE(ndbc.WDIR));




end

