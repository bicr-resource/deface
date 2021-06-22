function [varargout] = vb_matlab_version(varargin)
% This function is to know matlab version information.
% Usage: [major, minor, revision, build] = vb_matlab_version;
%        [comparative_result] = vb_matlab_version('==', '7.0.1');
%        [comparative_result] = vb_matlab_version('7.0.1');
%
% ----- Format1
% To get a version number.
%
% [major, minor, revision, build] = vb_matlab_version;
% [IN]
%     nothing
% [OUT]
%     major : MATLAB major version
%     minor : MATLAB minor version
%     revision : MATLAB revision
%     build : MATLAB build number
%
% ----- Format2
% To Compare with matlab and specified version.
% result = vb_matlab_version('==', '7.0.1');
% [IN]
%     comparative_operator : '>' or '<' or '>=' or '<=' or '==' or '~='
%     ver_str              : version string separated by '.'
%                            ex.'7', '7.0', '7.0.1', '7.0.1.24704'
% [OUT]
%     comparative_result : true or false.
%
% Examples
%       If the Matlab version is 7.1.0.83, and the user supplied version is '7':
%       status = vb_matlab_version('==', '7');
%       returns status == true   : major revision numbers are the same.
%
%       If the Matlab version is 7.1.0.83, and the user supplied version is '7.1':
%       status = vb_matlab_version('==', '7.1');
%       returns status == true   : major and minor revision numbers are the same.
%
%       If the Matlab version is 7.1.0.83, and the user supplied version is '7.1':
%       status = vb_matlab_version('>', '7.1');
%       returns status == false   : major and minor revision is later for matlab.
%
% ---- Format3
% To Compare with matlab and specified version.
% result = vb_matlab_version('7.0.1')
%  (This is same with vb_matlab_version('==', '7.0.1');)
% [IN]
%     ver_str : version string separated by '.'
%               ex.'7', '7.0', '7.0.1', '7.0.1.24704'
% [OUT]
%    comparative_result : true or false.
%
% See also:
%     MATLAB embedded function 'version'
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

SEP = '.'; % version separator

switch(nargin)
    case 0 % [major, minor, revision, build] = vb_matlab_version()
        [ret] = sscanf(strtok(version), ['%d' SEP], 4);
        varargout{1} = ret(1);
        varargout{2} = ret(2);
        varargout{3} = ret(3);
        varargout{4} = ret(4);
    case 1 % [comparative_result] = vb_matlab_version('7.0.1');
        input_str = varargin{1};
        if ~ischar(input_str)
            error('version string should be string.');
        end
        [result] = compare_version('==', input_str, SEP);
        varargout{1} = result;
    case 2 % [comparative_result] = vb_matlab_version('>=', '7.0.1')
        comparative_operator = varargin{1};
        input_str = varargin{2};
        if ~ischar(input_str)
            error('version string should be string.');
        end
        [result] = compare_version(comparative_operator, input_str, SEP);
        varargout{1} = result;
end

function [result] = compare_version(comparative_operator, ver_str, sep)

if numel(findstr(ver_str, sep)) > 3
    error('Input version string has too many fields. Only major.minor.release.build fields are supported.');
end

result = true;

[m_ver] = sscanf(strtok(version), ['%d' sep], 4);
[c_ver, count, errmsg, nextindex] = sscanf(ver_str, ['%d' sep], 4);
if ~isempty(errmsg)
    error(['Input version string is invalid at ' num2str(nextindex) ': ' ver_str]);
end

% Compare
% m_ver(1) m_ver(2) m_ver(3) m_ver(4)
%   |         |        |        |
% c_ver(1) c_ver(2) c_ver(3) c_ver(4)
% ------------> compare direction
%  k==1      k==2     k==3     k==4
for k=1:count
    if (m_ver(k) == c_ver(k)) && (k ~= count)
        % 最上位桁から下位方向へ向かって1桁ずつチェック
        % 同値の場合は、ひとつ下の桁に判断を先送りする。
        % 先送りして最下位桁まで行った場合は、
        % 同値でも下の比較演算子により比較結果を出力.
        continue;
    else
        % 比較演算子による比較.
        result = eval(['m_ver(k)' comparative_operator 'c_ver(k)']);
        return;
    end
end
