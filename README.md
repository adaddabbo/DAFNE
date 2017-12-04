# DAFNE
PAPER TITLE:
DAFNE: A Matlab Toolbox for Bayesian multi-source remote sensing and ancillary data fusion, with application to flood mapping

Authors: A.D'Addabbo, A. Refice, F.P. Lovergine, G. Pasquariello
          CNR-ISSIA,Via Amendola 122/D 70125 Bari, Italy
          daddabbo@ba.issia.cnr.it
          
Description: 
DAFNE is composed of 5 modules, written as functions in the Matlab programming language.
DAFNE I/O data can be considered in two different formats: a) native Matlab arrays, or b) binary files in GeoTIFF format. Matlab format should be preferred e.g. when large files have to be considered, because it allows to use the native Matlab interface for large files, using e.g. distributed arrays, or parallel file access and processing, as reported in the Matlab documentation. This could allow to speed up considerably the whole processing chain. The latter format is chosen for its large compatibility with many remotely sensed data processing tools, as well as geographic information systems (GIS). One assumption which is made in the present paper is that all the data sources have been pre-processed in order to coregister them to the same geometry. All the image data are assumed to be of the same size, so that different data resolutions have to be dealt with externally, e.g. by proper interpolation to a common grid.
DAFNE provides, as output products, P probability maps, depicting for each pixel the probability value that the corresponding area has been reached by the inundation. A probability map is produced for each date and time, during a ood event, in correspondence of which at least one image has been acquired.
An extended description of Input/output variables, files and parameters required by each DAFNE module is reported in the file: DAFNE_IO.pdf
