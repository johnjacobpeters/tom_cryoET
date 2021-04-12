classdef tom_logger < handle
%   tom_logger creates a logger object.
%   This oject can be used to generate logging on scrren and/or in a
%   logfile
%
%   logger=tom_logger('my_log.txt'); creates a logfile named my_log.txt    
%
%    Examples
%    --------
%    logger=tom_logger('my_log.txt');
%    logger.writeMessage('Hello World!','Info')
%    clear('logger'); 
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
    appendToFile = false;
    writeToFile = true;
    printToScreen= true;
    addDate=true;
    empytLines='none';
    messageClass='Info';
    maxWorkSpaceCharSize=20;
    WorkSpaceStart='====================================================>';
    WorkSpaceStop='<====================================================';
    verbose=true;
end

properties(SetAccess = protected)
    logFileName = '';
    fid='';
end

properties (Constant)
      possibleMessageClasses={'Info';'Debug';'Warning';'Error';'None'};
end

    
    methods
        
        function self = tom_logger(logFileName,appendToFile,writeToFile,printToScreen,addDate,empytLines,verbose)
            
            if (nargin>0)
                self.logFileName=logFileName;
            end;
            if (nargin>1)
                self.appendToFile=appendToFile;
            end;
            if (nargin>2)
                self.writeToFile=writeToFile;
            end;
            if (nargin>3)
                self.printToScreen=printToScreen;
            end;
            if (nargin>4)
                self.addDate=addDate;
            end;
            if (nargin>5)
                self.empytLines=empytLines;
            end;
            if (nargin>6)
                self.verbose=verbose;
            end;
            
            if (isempty(self.logFileName))
                self.writeToFile=false;
            else
                if (self.appendToFile)
                    fidMode='a';
                else
                    fidMode='wt';
                end;
                self.fid=fopen(self.logFileName,fidMode);
                fclose(self.fid);
            end;
            
        end
        
        function set.messageClass(self,messageClass)
             if (strcmp(messageClass,'None')==0)
                if (ismember(messageClass,self.possibleMessageClasses)==0) 
                    errorStr=sprintf('%s\n',[messageClass ' is not a valid message class valid classes are:']);
                    for ii=1:length(self.possibleMessageClasses)
                        tmp=sprintf('%s\n',self.possibleMessageClasses{ii});
                        errorStr=cat(2,errorStr,tmp);
                    end;
                    error('tom_logger:WrongMessageClass',errorStr);
                end;
             end;
             self.messageClass=messageClass;
        end   
        
        function writeMessage(self,message,messageClass,addDate,writeToFile,printToScreen,verbose)
            %writeMessage writes a message to logfile or screen
            %
            %   writeMessage(self,message,messageClass,addDate,writeToFile,printToScreen)
            %
            %PARAMETERS
            %
            %  INPUT
            %   message             reference image
            %   messageClass        ('Info') image to be aligned
            %   addDate             (true) add date to ouput 
            %   writeToFile         (true) write message to log-file
            %   printToScreen       (true) wirte message to screen 
            %   verbose             (true) write output      
            %
            %EXAMPLE
            %    logger=tom_logger('my_log.txt');
            %    logger.writeMessage('Hello World!','Error',true,true,true,true)
            %    clear('logger'); 
            %
            %REFERENCES
            %
            %SEE ALSO
            %   ...
            %
            
            
            tmpMessage='';
            
            if (nargin<3)
                messageClass=self.messageClass;
            end;
            if (nargin<4)
                addDate=self.addDate;
            end;
            if (nargin<5)
                writeToFile=self.writeToFile;
            end;
            if (nargin<6)
                printToScreen=self.printToScreen;
            end;
            if (nargin<7)
                verbose=self.verbose;
            end;
            
            if (verbose==false)
                return;
            end;
             
            if (addDate)
                tmpMessage=cat(2,tmpMessage,[datestr(now) ' ']);
            end;
            if (strcmp(messageClass,'None')==0)
                if (ismember(messageClass,self.possibleMessageClasses)==0) 
                    errorStr=sprintf('%s\n',[messageClass ' is not a valid message class valid classes are:']);
                    for ii=1:length(self.possibleMessageClasses)
                        tmp=sprintf('%s\n',self.possibleMessageClasses{ii});
                        errorStr=cat(2,errorStr,tmp);
                    end;
                    error('tom_logger:WrongMessageClass',errorStr);
                end;
                tmpMessage=cat(2,tmpMessage,[messageClass ' ']);
            end;
            
            if (isempty(message)==0)
                tmpMessage=cat(2,tmpMessage,[message ' ']);
            end;
            
            if (writeToFile)
                self.fid=tom_fopen(self.logFileName,'a');
                fprintf(self.fid,'%s\n',tmpMessage);
                fclose(self.fid);
            end;
            if (printToScreen)
                disp(tmpMessage);
            end;
        end
        
        function writeWorkSpace(self)
            %writeWorkSpace writes variables of workspace to logfile or screen
            %
            %   writeWorkSpace()
            %
            %PARAMETERS
            %
            %  INPUT
            %
            %
            %EXAMPLE
            %    clear all;
            %    numExample=1;
            %    stringExample='Hallo World!';
            %    matExample=rand(64,64,64); 
            %    logger=tom_logger('my_log.txt');
            %    logger.writeWorkSpace;
            %    clear('logger'); 
            %
            %REFERENCES
            %
            %SEE ALSO
            %   ...
            %
            workSpace=evalin('caller', 'whos();');
            writeMessage(self,self.WorkSpaceStart,'Info',false);
            for i=1:length(workSpace)
                if (strcmp(workSpace(i).name,'ans') || strcmp(workSpace(i).class,'tom_logger'))
                    continue;
                end;
                
                [wsString,doEval]=workSpaceEntry2String(self,workSpace(i));
                if (doEval)
                    variableContent=evalin('caller', workSpace(i).name);
                    variableContent=formatVariableContent(self,variableContent);
                else
                    variableContent=['[' num2str(workSpace(i).size) '] ' workSpace(i).class];
                end;
                wsString=[wsString variableContent];
                writeMessage(self,wsString,'Info',false);
            end;
            writeMessage(self,self.WorkSpaceStop,'Info',false);
        end
        
        
        
    end
    methods(Access = private)
        function [wsString,doEval]=workSpaceEntry2String(self,wsEntry)
           
           doEval=0;
           wsString=[wsEntry.name ': ' ]; 
           if (strcmp(wsEntry.class,'char'))
               if (length(wsEntry.size)<3)
                    if (isempty(find([wsEntry.size]==1))==0 );
                        doEval=1;
                    end;
               end;
               
           end;
           if (strcmp(wsEntry.class,'double') || strcmp(wsEntry.class,'single') || isempty(findstr(wsEntry.class,'int'))==0 )
               if (length(wsEntry.size)<3)
                    if (isempty(find([wsEntry.size]==1))==0 );
                        doEval=1;
                    end;
               end;
          end;
           
        end
        function cont=formatVariableContent(self,cont)
            if (isnumeric(cont))
                cont=num2str(cont);
            end;
            if (length(cont) > self.maxWorkSpaceCharSize )
                cont=cont(1:self.maxWorkSpaceCharSize);
            end
        end
    end
end




