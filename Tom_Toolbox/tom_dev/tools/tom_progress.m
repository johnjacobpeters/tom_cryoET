classdef tom_progress < handle
%    tom_progress creates a waitbar object.
%    This oject can be used to display a comandline waitbar which also works
%    4 parfor loops
%
%    waitbar=tom_progress(50,'...Running'); creates a waitbar with max num 50
%    and title 'Running'    
%
%    Examples
%    --------
%    parpool('local', 8);
%    waitbar=tom_progress(100,'Test Parfor Run'); 
%    parfor i=1:100
%      pause(rand(1)*2);   
%      waitbar.update();
%    end;
%    waitbar.close;       %normal destructor is no used due to matlabs parfor behaviour 
%    clear('waitbar'); 
%   
%   created by FB 
%   Nickell et al., 'TOM software toolbox: acquisition and analysis for electron tomography',
%   Journal of Structural Biology, 149 (2005), 227-234.
%
%   Copyright (c) 2004-2007
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute of Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom   
    
    properties(SetAccess = public)
        finalOutput='done.';
        verbose=1;
    end
    
    properties(SetAccess = protected)
        title='';
        startTime=0;
        fid='';
        tmpProgressFileName=[];
        NumOfEntries=0;
        sizeOfWaitbar=50;
        backSpaceOffSet=6;
        sizeOfTimeStr=17;
    end
    
    
    methods
        function self = tom_progress(NumOfEntries,title,verbose,sizeOfWaitbar)
            if (nargin>1)
               self.title=title;
            end;
            if (nargin>2)
               self.verbose=verbose;
            end;
            if (nargin>3)
               self.sizeOfWaitbar=sizeOfWaitbar;
            end;
            
            self.tmpProgressFileName=[tempdir strrep(strrep(datestr(now),' ','-'),':','-') num2str(rand) '.deltxt'];
            tmpFid=fopen(self.tmpProgressFileName,'w');
            if (tmpFid<0)
                 self.tmpProgressFileName=[strrep(datestr(now),' ','-') num2str(rand) '.deltxt'];
                 tmpFid=fopen(self.tmpProgressFileName,'w');
                 if (tmpFid<0)
                      error('tom_progress:TempFileError',['Cannot open TempFile: ' self.tmpProgressFileName]);
                 end;
            end;
            
            
            self.startTime=clock;
            self.NumOfEntries=NumOfEntries;
            if (self.verbose==1)
                printTitle(self)
                printWaitbar(self,0,sprintf(['%' num2str(self.sizeOfTimeStr) 's'],'0/0 sec'));
            end;
        end
        
        function update(self)
            %updates waitbar 
            %
            %   update()
            %
            %PARAMETERS
            %
            %  INPUT
            %   -
            %
            %  EXAMPLE
            %  waitbar=tom_progress(100,'Test Parfor Run'); 
            %  for i=1:100
            %     pause(rand(1)*2);   
            %     waitbar.update();
            %   end;
            %   waitbar.close;       %normal destructor is no used due to matlabs parfor behaviour 
            %   clear('waitbar'); 
            %
            %REFERENCES
            %
            %SEE ALSO
            %   ...
            %
            if (self.verbose==0)
                return;
            end;
            percentDone=getPercentDone(self);
            [diffTime,estimatedTotalTime]=calcTime(self,percentDone);
            timeStr=self.time2string(diffTime,estimatedTotalTime);
            printWaitbar(self,percentDone,timeStr)
         end
        
        function close(self)
            if (self.verbose==1)
                disp(self.finalOutput);
            end;
            warning off;
            delete(self.tmpProgressFileName);
            warning on;
       end
        
    end
    
    methods(Access = private)
        
        function printWaitbar(self,percentDone,timeStr)
             numOfBackSpace=self.sizeOfTimeStr+ self.sizeOfWaitbar+self.backSpaceOffSet;
             backSpace=repmat(char(8), 1, numOfBackSpace);
             newLine=char(10);
             wbStart='[';
             wbProgr=[repmat('=', 1, round(percentDone*self.sizeOfWaitbar/100))  '>'];
             wbEmpty=repmat(' ', 1, self.sizeOfWaitbar - round(percentDone* self.sizeOfWaitbar/100));
             wbEnd=']';
             waitBarString=[backSpace,newLine,timeStr,wbStart,wbProgr,wbEmpty,wbEnd];
             disp(waitBarString);    
        end;
        
        
        function percentDone=getPercentDone(self)
            f = fopen(self.tmpProgressFileName, 'a');
            fprintf(f, '1\n');
            fclose(f);
            f = fopen(self.tmpProgressFileName, 'r');
            progress = fscanf(f, '%d');
            fclose(f);
            percentDone = length(progress)/self.NumOfEntries*100;
        end;
       
        function printTitle(self)
            tmpStr=[self.title repmat(' ',1,self.sizeOfTimeStr+self.backSpaceOffSet+self.sizeOfWaitbar -length(self.title)+20)];
            disp(tmpStr);
            disp('                        ');
        end;
        
        function [diffTime,estimatedTotalTime]=calcTime(self,percent)
            timeNow=clock;
            diffTime=etime(timeNow,self.startTime);
            estimatedTotalTime=diffTime.*(100./percent);
        end;
        
        function timeStr=time2string(self,time1,time2)
            if (time2 < 60)
                unitStr='sec';
                deNominator=1;
            end;
            
            if (time2 > 60 && time2 < 3600)
                unitStr='min';
                deNominator=60;
            end;
            
            if (time2 > 3600)
                unitStr='hours';
                deNominator=3600;
            end;
            
            time1Str=sprintf('%.2f',time1./deNominator);
            time2Str=sprintf('%.2f',time2./deNominator);
            tmpStr=[time1Str '/' time2Str ' ' unitStr ];
            timeStr=sprintf(['%' num2str(self.sizeOfTimeStr) 's '],tmpStr);
        end;
        
    end;
    
    
end


