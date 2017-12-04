function [p_F_K]=electromagnetic_modelling(Ch_flag_filename,Ch_type,mu_Ch,varargin)
%This function is distributed under the terms of the GNU General Public License 2.0 or
%any later version. See http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
%for the text of the license.

if nargin==3 th=[];  db_th_delta=[]; output_file_flag=[];
elseif nargin==4 th=varargin{1,1}; db_th_delta=[]; output_file_flag=[];
elseif nargin==5 th=varargin{1,1}; db_th_delta=varargin{1,2}; output_file_flag=[]; 
elseif nargin==6 th=varargin{1,1}; db_th_delta=varargin{1,2}; output_file_flag=varargin{1,3};end

%% reading flag input file

fid2=fopen(Ch_flag_filename,'r');
data2=textscan(fid2,'%s %d');
data_aq_date=datenum(data2{1,1});
flood_flag_date=cast(data2{1,2},'logical');
fclose(fid2);
clear data2

%% reading mu_Ch, controlling if it is written in a file

if(ischar(mu_Ch))
    mu_C_filename=mu_Ch;
    data=readtable(mu_C_filename,'Delimiter','\t','ReadVariableNames',false);
    Ch_mu=table2array(data(:,1:end-1));
    clear data
else
    Ch_mu=mu_Ch;
end

clear mu_Ch

%% setting th value (and control the db flag) if it is not set by the user

db_flag='NO';

if(strcmpi(Ch_type,'int'))
    if(isempty(th))
        th=-13;
    end
    delta=1;
    if(size(db_th_delta,2)==3)
        db_flag='YES';
    end
elseif(strcmpi(Ch_type,'coh'))
    if(isempty(th))
        th=0.2;
    end
    delta=0.1;
 elseif(strcmpi(Ch_type,'ndvi'))
    if(isempty(th))
        th=-0.2;
    end
    delta=0.05;
end

%% variables inizialization    
if(strcmpi(Ch_type,'coh')==1)
    Ch_mu_tmp=Ch_mu;
    Ch_mu=[];
    for i=1:size(Ch_mu_tmp,2)
       Ch_mu=[Ch_mu repmat(Ch_mu_tmp(:,i),1,2)]; 
    end
    clear Ch_mu_tmp
end
     
%% p_F_K computation 

ind=find(flood_flag_date==1);
p_F_K_tmp =zeros(size(ind,1),size(Ch_mu,1)); 

if size(find(flood_flag_date==0),1)==0 
    
    for i=1:size(ind,1)
        for j=1:size(Ch_mu,1)
            if (Ch_mu(j,ind(i))<=th)
                p_F_K_tmp(i,j)=0.9;
            else
                p_F_K_tmp(i,j)=0.1; 
            end
        end
    end
    
else
    
    mu_NF=mean(Ch_mu(:,flood_flag_date==0),2);
    
    for i=1:size(ind,1) 
        delta_F_NF=mu_NF - Ch_mu(:,ind(i));
        for j=1:size(Ch_mu,1)
           if (Ch_mu(j,ind(i))<=th)
               if(delta_F_NF(j,1)>delta)
                   p_F_K_tmp(i,j)=0.9;
               else 
                   if(strcmpi(Ch_type,'coh')==0)
                       p_F_K_tmp(i,j)=0.1;
                   else
                       p_F_K_tmp(i,j)=0.5;
                   end
               end               
           else
               if(strcmpi(Ch_type,'int')==1 && strcmpi(db_flag,'YES') &&...
                       ((Ch_mu(j,ind(i))>db_th_delta(1,1) &&...
                        Ch_mu(j,ind(i))<=db_th_delta(1,2)) && ...
                        delta_F_NF(j,1)<db_th_delta(1,3)))
                    p_F_K_tmp(i,j)=0.5;
               else
                   p_F_K_tmp(i,j)=0.1;
               end
           end      
        end
    end
end

%% output variables creation

for k=1:size(p_F_K_tmp,1)
    
    fieldname(k,:) = datestr(data_aq_date(ind(k),1),'mmm_dd_yyyy');
    p_F_K.(fieldname(k,:)) = p_F_K_tmp(k,:);
    
end

%% writing output files

if(output_file_flag==1)
    output_filename=strcat('P_F_C',num2str(size(p_F_K_tmp,2)),'_',Ch_type,'.txt');
    fid4=fopen(output_filename,'w');   
    for i=1:size(p_F_K_tmp,1)
        fprintf(fid4,'%s\t',fieldname(i,:));
        for j=1:size(p_F_K_tmp,2)
            fprintf(fid4,'%1.3f\t',p_F_K_tmp(i,j));
        end
         fprintf(fid4,'\n');
    end  
    fclose(fid4);   
end