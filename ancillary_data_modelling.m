function [p_F_a]=ancillary_data_modelling(ancillary_data,ancillary_data_type,A_date_par_filename,model_function_type,varargin)
%This function is distributed under the terms of the GNU General Public License 2.0 or
%any later version. See http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
%for the text of the license.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List of ancillary data type allowed:
% 1.'distance'
% 2.'gfi'
%
% List of model function type available:
% 1.Linear ------>parameters required:th1,th2
% 2.Sigmoidal --->parameters required:sigma,mu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% reading input data

if(ischar(ancillary_data))

    [data, R] = geotiffread(ancillary_data);
    a=reshape(data,1,size(data,1)*size(data,2));
    info=geotiffinfo(ancillary_data);
    
else
    data=ancillary_data;
    clear ancillary_data
    ancillary_data=1; %useful for the control to write geoTIFF output files
    a=reshape(data,1,size(data,1)*size(data,2));
end

%% reading flag input file

fid2=fopen(A_date_par_filename,'r');
data2=textscan(fid2,'%s %f %f');
ancillary_data_date=datenum(data2{1,1});
parameter=[data2{1,2} data2{1,3}];
fclose(fid2);

%% computing p_F_a

for k=1:size(ancillary_data_date,1)
    % si considera il caso in cui i flag non sono scritti correttamente  
    if sum(strcmpi(ancillary_data_type,'distance'))>0
        if sum(strcmpi(model_function_type,'linear'))>0
            
            m=min(parameter(k,:));
            M=max(parameter(k,:));
            
            p_F_a_tmp(k,:)=max(min((a-M)/(m-M),1),0);
            
        elseif sum(strcmpi(model_function_type,'sigmoidal'))>0
            p_F_a_tmp(k,:)=sigmf(a,[-parameter(k,1) parameter(k,2)]);
        else
            p_F_a_tmp(k,:)= repmat(0.5,1,size(data,1)*size(data,2));
        end
        
    elseif sum(strcmpi(ancillary_data_type,'gfi'))>0
        if sum(strcmpi(model_function_type,'linear'))>0
            
            m=min(parameter(k,:));
            M=max(parameter(k,:));
            
            p_F_a_tmp(k,:)=max(min((a-m)/(M-m),1),0);
            
        elseif sum(strcmpi(model_function_type,'sigmoidal'))>0
            p_F_a_tmp(k,:)=sigmf(a,[parameter(k,1) parameter(k,2)]);
        else
            p_F_a_tmp(k,:)= repmat(0.5,1,size(data,1)*size(data,2));
        end
    else
        p_F_a_tmp(k,:)= repmat(0.5,1,size(data,1)*size(data,2));
    end
    
%% output variables creation

fieldname = datestr(ancillary_data_date(k,1),'mmm_dd_yyyy');
p_F_a_tmp2= reshape(p_F_a_tmp(k,:),size(data,1),size(data,2));
p_F_a.(fieldname) = p_F_a_tmp2;
    
%% writing output files
    if(nargin==5 && ischar(ancillary_data))
        if(varargin{1,1}==1)
        output_filename=strcat('p_F_A_',ancillary_data_type,'_F_',fieldname,'.tif');  
        geotiffwrite(output_filename,p_F_a_tmp2,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);                
        end
    end
end