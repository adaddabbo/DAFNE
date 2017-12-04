function [mu_Ch_K,p_Ch_K,p_K]=image_segmentation(Ch_img,varargin)
%This function is distributed under the terms of the GNU General Public License 2.0 or
%any later version. See http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
%for the text of the license.

%% reading imagery data

if(ischar(Ch_img))
    
    fid1=fopen(Ch_img,'r');
    Data=textscan(fid1,'%s');
    n_images=size(Data{1,1},1);
    
    for i=1:n_images
        
        img_filename=cast(Data{1,1}(i,1),'char');
        [img, R] = geotiffread(img_filename);
        
        Ch(:,i)=reshape(img,size(img,1)*size(img,2),1);
    end
    
    fclose(fid1);
    info=geotiffinfo(img_filename);
    
else
    img=Ch_img;
    n_images=size(img,3);
    
    for i=1:n_images       
        Ch(:,i)=reshape(img(:,:,i),size(img,1)*size(img,2),1);
    end
end


%% kmeans computation
%k means input parameter setting---------------------
max_iter=10000;
n_rep=1;

if(nargin==1 || (nargin>=2 && isempty(varargin{1,1})))
    n_K=8*n_images;
else
    n_K=varargin{1,1};
end
    
%-------------------------

ops = statset('MaxIter',max_iter);

[IDX, mu_Ch_K] = kmeans(Ch,n_K,'options',ops,'replicates',n_rep);


%% Output variables computation

%Not NaN number computation
idx_pxl_Not_Nan=~isnan(IDX);
n_IDX_Not_Nan=sum(idx_pxl_Not_Nan);

for i=1:n_K
    covariance=cov(Ch(find(IDX==i),:));
    
    % p_ch_K and p_K computation
    p_Ch_K(:,:,i)=reshape(mvnpdf(Ch,mu_Ch_K(i,:),covariance),size(img,1),size(img,2));
    p_K(i,1)=size(find(IDX==i),1)/n_IDX_Not_Nan;
    
    clear covariance
end

mu_Ch_K=mu_Ch_K';

clear IDX ops

%% writing output files
if(nargin>=3 && ~isempty(varargin{1,2}))
    if(varargin{1,2}==1 || varargin{1,2}==2)
       if(nargin==4 && ischar(varargin{1,3}))
           outputfilename2=strcat('p_C',varargin{1,3},'.txt');
           outputfilename3=strcat('mu_C',varargin{1,3},'.txt');
       else           
           outputfilename2=strcat('p_C.txt');
           outputfilename3=strcat('mu_C.txt');
       end
       fid2=fopen(outputfilename2,'w');
       fid3=fopen(outputfilename3,'w');
       
       for i=1:n_K
           if(varargin{1,2}==2 && ischar(Ch_img))
               if(nargin==4 && ischar(varargin{1,3}))
                  output_filename1=strcat('p_I',varargin{1,3},'_C',num2str(i),'.tif');
               else
                  output_filename1=strcat('p_I_C',num2str(i),'.tif');
               end
               geotiffwrite(output_filename1,p_Ch_K(:,:,i),R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
           end
           
        fprintf(fid2,'%1.3f\n',p_K(i,1));
                for j=1:n
                    fprintf(fid3,'%f\t',mu_Ch_K(j,i));
                end
                fprintf(fid3,'\n');        
       end
       fclose(fid2);
       fclose(fid3);        
    end
end

end