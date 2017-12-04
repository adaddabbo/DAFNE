function [p_Ch_F,p_Ch_NF]=compute_P_Ch_F(p_Ch_K,p_K,p_F_K)
%This function is distributed under the terms of the GNU General Public License 2.0 or
%any later version. See http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
%for the text of the license.

%p_F_K is a column vector

p_NF_K= ones(size(p_F_K)) - p_F_K;
   
%p(K|F) and P(K|NF) computation
p_K_F=(p_F_K.*p_K')./(p_F_K*p_K);
p_K_NF=(p_NF_K.*p_K')./(p_NF_K*p_K);

%p(Ch|F) and p(Ch|NF) computation

p_Ch_F=p_K_F*p_Ch_K;
p_Ch_NF=p_K_NF*p_Ch_K;