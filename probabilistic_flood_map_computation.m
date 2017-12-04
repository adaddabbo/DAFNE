function [p_F_i_A]=probabilistic_flood_map_computation(imagery_source_number,ancillary_data_number,varargin)
%This function is distributed under the terms of the GNU General Public License 2.0 or
%any later version. See http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
%for the text of the license.

%% variables initialization

n_flood_img_for_source=zeros(imagery_source_number,1);
flood_date_for_img_source=[];
p_i_F=[];
p_i_NF=[];

if(ancillary_data_number~=0)
    n_flood_a_for_source=zeros(ancillary_data_number,1);
else
     n_flood_a_for_source=ancillary_data_number;
end
a_date_for_img_source=[];
p_F_A=[];
info=[];
R=[];

%% reading p_I_F and P_I_NF (da varargin{1,1} a varargin{1,imagery_number}) if it is written in a file 

for i=1:imagery_source_number %non � considerato il caso in cui imagery_source_number=0
    
    if(ischar(varargin{1,i}))
        
        p_i_F_NF_filename_list=varargin{1,i};
        fid1=fopen(p_i_F_NF_filename_list,'r');
        data1=textscan(fid1,'%s %s %s');
        imagery_data_date=datenum(data1{1,1});
        
        p_i_F_filename_list=data1{1,2};%la prima img per ogni data deve essere quella di flood
        p_i_NF_filename_list=data1{1,3};
        fclose(fid1);
        clear data1
        
        for j=1:size(imagery_data_date,1)
            img_filename_F= p_i_F_filename_list{j};
            [img_F, R] = geotiffread(img_filename_F);
            p_i_F=[p_i_F;reshape(img_F,1,size(img_F,1)*size(img_F,2))];
            
            img_filename_NF= p_i_NF_filename_list{j};
            [img_NF, R] = geotiffread(img_filename_NF);
            p_i_NF=[p_i_NF;reshape(img_NF,1,size(img_NF,1)*size(img_NF,2))];
            
        end
        info=geotiffinfo(img_filename_F);
        r=size(img_NF,1);
        c=size(img_NF,2);
    else
        imagery_data_date=datenum(fieldnames(varargin{1,i}));
        
        for j=1:size(imagery_data_date,1)
            fieldname_i=datestr(imagery_data_date(j),'mmm_dd_yyyy');
            p_i_F_NF=getfield(varargin{1,i},fieldname_i);
            p_i_F=[p_i_F;reshape(p_i_F_NF.F,1,size(p_i_F_NF.F,1)*size(p_i_F_NF.F,2))];
            p_i_NF=[p_i_NF;reshape(p_i_F_NF.NF,1,size(p_i_F_NF.NF,1)*size(p_i_F_NF.NF,2))];
        end
        r=size(p_i_F_NF.NF,1);
        c=size(p_i_F_NF.NF,2);
    end
    
    n_flood_img_for_source(i,1)=size(imagery_data_date,1);
    flood_date_for_img_source=[flood_date_for_img_source; imagery_data_date];
end

%% reading p_A_F (da varargin{1,imagery_number+1} a varargin{1,imagery_number+ancillary_data_number}) if it is written in a file

if(ancillary_data_number~=0)
    for i=1:ancillary_data_number
        
        if(ischar(varargin{1,imagery_source_number+i}))
            
            p_A_F_filename_list=varargin{1,imagery_source_number+i};
            fid2=fopen(p_A_F_filename_list,'r');
            data2=textscan(fid2,'%s %s');
            ancillary_data_date=datenum(data2{1,1});
            p_A_F_filename_list=data2{1,2};
            fclose(fid2);
            clear data2
            
            for j=1:size(ancillary_data_date,1)
                a_filename_F= p_A_F_filename_list{j};
                [a_F, R] = geotiffread(a_filename_F);
                p_F_A=[p_F_A;reshape(a_F,1,size(a_F,1)*size(a_F,2))];
                
                clear a_F 
            end
            info=geotiffinfo(a_filename_F);
        else
            ancillary_data_date=datenum(fieldnames(varargin{1,imagery_source_number+i})); %controllare che datenum vada bene con un cell array
            
            for j=1:size(ancillary_data_date,1)
                fieldname_a=datestr(ancillary_data_date(j),'mmm_dd_yyyy');
                p_F_A_tmp=getfield(varargin{1,imagery_source_number+i},fieldname_a);
                p_F_A=[p_F_A;reshape(p_F_A_tmp,1,size(p_F_A_tmp,1)*size(p_F_A_tmp,2))];
                clear p_F_A_tmp
            end
        end
        n_flood_a_for_source(i,1)=size(ancillary_data_date,1);
        a_date_for_img_source=[a_date_for_img_source; ancillary_data_date];
    end
else
    a_date_for_img_source=0;
end

%% control on the flood map dates

[flood_map_date, ind,flood_map_ind]=unique(flood_date_for_img_source);
clear ind

%% compute final map

for i=1:size(flood_map_date,1)
    fieldname=datestr(flood_map_date(i),'mmm_dd_yyyy');
    n_img=size(find(flood_map_ind==i),1);
    if(n_img>1)
        p_i_F_tot=prod(p_i_F(find(flood_map_ind==i),:));
        p_i_NF_tot=prod(p_i_NF(find(flood_map_ind==i),:));
    else
        p_i_F_tot=p_i_F(find(flood_map_ind==i),:);
        p_i_NF_tot=p_i_NF(find(flood_map_ind==i),:);
    end

    ind_a=ismember(a_date_for_img_source,flood_map_date(i));
    if(sum(ind_a)==0)
        p_F_A_tot=ones(1,size(p_i_F_tot,2));
        p_NF_A_tot=ones(1,size(p_i_F_tot,2));
    elseif(sum(ind_a)==1)
        p_F_A_tot=p_F_A(find(ind_a),:);   
        p_NF_A_tot=1-p_F_A_tot;
    else
        p_F_A_tot=prod(p_F_A(find(ind_a),:))./sum(p_F_A(find(ind_a),:));
        p_NF_A_tot=1-p_F_A_tot;
    end
    
    num=p_i_F_tot.*p_F_A_tot;
    den=p_i_NF_tot.*p_NF_A_tot;
    
    p_F_i_A_tmp = num ./(num+den);
    
    p_F_i_A.(fieldname)= reshape(p_F_i_A_tmp,r,c);
    clear num den *_tot
    
    %% writing output files
    if(nargin==3+imagery_source_number+ancillary_data_number && ~isempty(R))
        if(varargin{1,1+imagery_source_number+ancillary_data_number}==1)
        output_filename=strcat('p_F_map_I_',num2str(imagery_source_number),'_A_',num2str(ancillary_data_number),'_',fieldname,'.tif');  
        geotiffwrite(output_filename,p_F_i_A.(fieldname),R,'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
        end
    end
    clear fieldname 
end