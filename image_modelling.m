function [p_Ch_F_NF]=image_modelling(p_i_C,p_C,p_F_C,varargin)  
%This function is distributed under the terms of the GNU General Public License 2.0 or
%any later version. See http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
%for the text of the license.

%% variables initialization

p_Ch_K=[];

%% reading p_Ch_K, controlling if it is written in a file or riorganize the p_Ch_K variable in dimensions

if(ischar(p_i_C))
    
    p_Ch_K_filename_list=p_i_C;
    fid1=fopen(p_Ch_K_filename_list,'r');
    data1=textscan(fid1,'%s');
    
    n_K=size(data1{1,1},1);
    
    for i=1:n_K
        
        img_filename=cast(data1{1,1}(i,1),'char');
        [img, R] = geotiffread(img_filename);
        
        p_Ch_K=[p_Ch_K;reshape(img,1,size(img,1)*size(img,2))];
    end
    
    fclose(fid1);
    info=geotiffinfo(img_filename);
    r=size(img,1);
    c=size(img,2);
    clear data1 
    
else
    
    p_Ch_K_input=p_i_C;
    n_K=size(p_Ch_K_input,3);
    
    for i=1:n_K 
        p_Ch_K(i,:)=reshape(p_Ch_K_input(:,:,i),1,size(p_Ch_K_input,1)*size(p_Ch_K_input,2));  
    end
    
    r=size(p_Ch_K_input,1);
    c=size(p_Ch_K_input,2);
    clear p_Ch_K_input 
end


%% reading p_K, controlling if it is written in a file

if(ischar(p_C))
    p_K_filename=p_C;
    fid2=fopen(p_K_filename,'r');
    data2=textscan(fid2,'%f');
    p_K=data2{1,1};
    fclose(fid2);
    clear data2
else
    p_K=p_C;
    
end
clear p_C

%% reading p_F_K, controlling if it is written in a file

if(ischar(p_F_C))
    p_F_K_filename=p_F_C;
    fid3=fopen(p_F_K_filename,'r');
    data3_tmp=textscan(fid3,'%s');
    data3=reshape(data3_tmp{1,1},n_K+1,mod(size(data3_tmp{1,1},1),n_K));
    
    varnames=data3(1,:)';
    p_F_K_tmp=num2cell(str2double(data3(2:n_K+1,:)'),2);
    clear data3_tmp data3
else
    p_F_K=p_F_C;
    varnames=fieldnames(p_F_K);
    p_F_K_tmp=struct2cell(p_F_K);
    clear p_F_K
end
clear p_F_C
%% Compute image model (p_Ch_F p_Ch_NF)

for i =1:size(p_F_K_tmp,1)
    [p_Ch_F_tmp,p_Ch_NF_tmp]=compute_P_Ch_F(p_Ch_K,p_K,p_F_K_tmp{i});
    p_Ch_F=reshape(p_Ch_F_tmp,r,c);
    p_Ch_NF=reshape(p_Ch_NF_tmp,r,c);
    p_Ch_F_NF.(varnames{i}).F=p_Ch_F; 
    p_Ch_F_NF.(varnames{i}).NF=p_Ch_NF;
    
    %% writing output files
    if(nargin>=4 && ~isempty(varargin{1,1}) && varargin{1,1}==1 && ischar(p_i_C))
        if(nargin==5 && ischar(varargin{1,2}))
            output_filename1=strcat('p_I_',varargin{1,2},'_F_',varnames{i},'.tif');
            output_filename2=strcat('p_I_',varargin{1,2},'_NF_',varnames{i},'.tif');
        else
            output_filename1=strcat('p_I_F_',varnames{i},'.tif');
            output_filename2=strcat('p_I_NF_',varnames{i},'.tif'); 
        end
        geotiffwrite(output_filename1,p_Ch_F,R,'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);        
        geotiffwrite(output_filename2,p_Ch_NF,R,'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);        
    end
    clear p_Ch_F_tmp p_Ch_NF_tmp p_Ch_F p_Ch_NF
end