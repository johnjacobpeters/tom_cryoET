function tom_HT_fastinsert(connect,tableName,fieldNames,data)
%FASTINSERT Export MATLAB cell array data into database table.
%   FASTINSERT(CONNECT,TABLENAME,FIELDNAMES,DATA). 
%   CONNECT is a database connection handle structure, FIELDNAMES
%   is a string array of database column names, TABLENAME is the 
%   database table, DATA is a MATLAB cell array. 
%
%
%   Example:
%
%
%   The following FASTINSERT command inserts the contents of
%   the cell array in to the database table yearlySales
%   for the columns defined in the cell array colNames.
%
% 
%   fastinsert(conn,'yearlySales',colNames,monthlyTotals);
%
%   where 
%
%   The cell array colNames contains the value:
%
%   colNames = {'salesTotal'};
%
%   monthlyTotals is a cell array containing the data to be
%   inserted into the database table yearlySales
%   
%   fastinsert(conn,'yearlySales',colNames,monthlyTotals);
%
%
%   See also INSERT, UPDATE.	

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $	$Date: 2008/05/12 21:23:42 $%

error(nargchk(4,4,nargin));

% Check for valid connection

if isa(connect.Handle,'double')
   
    error('database:fastinsert:invalidConnection','Invalid connection.')
   
end

% Create start of the SQL insert statement
% First get number of columns in the cell array 

%Get dimensions of data
switch class(data)
    
  case {'cell','double'}
    [numberOfRows,cols] = size(data);	%data dimensions
    
  case 'struct'
    sflds = fieldnames(data);
    fchk = setxor(sflds,fieldNames);
    if ~isempty(fchk)
      error('database:fastinsert:fieldMismatch','Structure fields and insert fields do not match.')
    end
    numberOfRows = size(data.(sflds{1}),1);
    %numberOfRows=1;
    cols = length(sflds);
    
    %Get class type of each field to be used later
    numberOfFields = length(sflds);
    fieldTypes = cell(numberOfFields,1);
    for i = 1:numberOfFields
      fieldTypes{i} = class(data.(sflds{i}));
    end

  otherwise
    error('database:fastinsert:inputDataError','Input data must be a cell array, matrix, or structure')
   
end

% Case 1 all fields are being written to in the target database table.
insertField = '';
tmpq = '';

% Create the field name string for the INSERT statement .. this defines the
% fields in the database table that will be receive data.
% Also build variable ?'s string for later set* commands

for i=1:cols,
  if ( i == cols),
    insertField = [ insertField fieldNames{i}];  %#ok
    tmpq = [tmpq '?)'];                          %#ok
  else
    insertField = [ insertField fieldNames{i} ',' ]; %#ok
    tmpq = [tmpq '?,'];                              %#ok
  end	
end

% Create the head of the SQL statement
startOfString = [ 'INSERT INTO '  tableName ' (' insertField ') ' 'VALUES ( ' ];

% Get NULL string and number preferences 
prefs = setdbprefs({'NullStringWrite','NullNumberWrite'});
nsw = prefs.NullStringWrite;
nnw = str2num(prefs.NullNumberWrite);    %#ok

%Create prepared statement object
tmpConn = connect.Handle;
StatementObject = tmpConn.prepareStatement([startOfString tmpq]);

%Determine type values by fetching one row of data from table

% buggy statement 
%e = exec(connect,['SELECT ' insertField ' FROM ' tableName]);

%fetches the whole table ...not the first row!!!!!!
% ...java.lang.OutOfMemoryError: Java heap space error accurs if 
%the number of entries is too big!!!

%fix for mysql ...is fecting only one row!!
e = exec(connect,['SELECT ' insertField ' FROM ' tableName ' LIMIT 1']);



if ~isempty(e.Message)
  error('database:database:insertError',e.Message)
end
e = fetch(e,1);
if ~isempty(e.Message)
  error('database:database:insertError',e.Message)
end
a = attr(e);
close(e)

for i = 1:numberOfRows,  
  
    for j = 1:cols
     
      switch class(data)
        
        case 'cell'

          tmp = data{i,j}; 
          
        case 'double'
            
          tmp = data(i,j);     
        
        case 'struct'
          
          switch fieldTypes{j}
            
            case 'cell'
          
              tmp = data.(sflds{j}){i};
          
            case 'double'
              
              tmp = data.(sflds{j})(i);
              
          end
        
      end  
      
      %Check for null values and setNull if applicable
      if (isa(tmp,'double')) & ...
         ((isnan(tmp) | (isempty(tmp) & isempty(nnw))) | (~isempty(nnw) & ~isempty(tmp) & tmp == nnw) | (isnan(tmp) & isnan(nnw)))  %#ok
          
         StatementObject.setNull(j,a(j).typeValue)
        
      elseif (isnumeric(tmp) && isempty(tmp))
        
        % Insert numeric null (for binary objects), using -4 fails
        StatementObject.setNull(j,7)
      
      elseif (isa(tmp,'char')) && ...
             ((isempty(tmp) && isempty(nsw)) || strcmp(tmp,nsw))
      
         StatementObject.setNull(j,a(j).typeValue)
      
      else
        
        switch a(j).typeValue
         
          case -7
            StatementObject.setBoolean(j,tmp)  %BIT
          case -6
            StatementObject.setByte(j,tmp)  %TINYINT
          case -5
            StatementObject.setLong(j,tmp)  %BIGINT
          case {-4, -3, 2004}
            StatementObject.setBytes(j,tmp)  %LONGVARBINARY, VARBINARY
          case {-10, -9, -8, -1, 1, 12}
            StatementObject.setString(j,java.lang.String(tmp))  %CHAR, LONGVARCHAR, VARCHAR
          case {2, 3, 7}
            StatementObject.setDouble(j,tmp)  %NUMERIC, DECIMAL, REAL
          case 4
            StatementObject.setInt(j,tmp)  %INTEGER
          case 5
            StatementObject.setShort(j,tmp)  %SMALLINT
          case 6
            StatementObject.setDouble(j,tmp)  %FLOAT
          case 8
            StatementObject.setDouble(j,tmp)  %DOUBLE
          case 91
            dt = datevec(tmp);
            StatementObject.setDate(j,java.sql.Date(dt(1)-1900,dt(2)-1,dt(3)))  %DATE
          case 92
            tt = datevec(tmp);
            StatementObject.setTime(j,java.sql.Time(tt(4),tt(5),tt(6)))  %TIME
          case 93
            ts = datevec(tmp);
            StatementObject.setTimestamp(j,java.sql.Timestamp(ts(1)-1900,ts(2)-1,ts(3),ts(4),ts(5),ts(6),0))  %TIMESTAMP
          case {-2,1111}
            error('database:fastinsert:unsupportedDatatype',['Unsupported data type in field ' fieldNames{j}])
          otherwise
            StatementObject.setObject(j,tmp);   %OBJECT
            
        end   %End of switch
      end  %End of datatype and null value check
    end  %End of j loop

    % Add parameters to statement object
    StatementObject.addBatch;
  
end  % End of numberOfRows loop

%Execute prepared statement batch
StatementObject.executeBatch;

close(StatementObject)
