program main;

uses sysutils,Manager,SharedTypes,RequestQueue;


procedure Create(cName: tCenterName; totalVotes: tNumVotes; var Mng: tManager);
begin
   if InsertCenter(cName,totalVotes,Mng) then
      writeln('* Create: center ',cName,' totalvoters ',totalVotes:0)
   else writeln('+ Error: Create not possible');
end;

procedure New();
begin

end;

procedure Vote();
begin
end;

procedure Remove();
begin
end;

procedure Stats();
begin
end;

procedure readTasks(filename:string);

VAR
   usersFile              : text;
   line                   : string;
   code                   : string;
   param1,param2, request : string;
   Mng                    : tManager;
   QItem                  : tItemQ;
   Queue                  : tQueue;


begin


   {proceso de lectura del fichero filename }

   {$i-} { Deactivate checkout of input/output errors}
   Assign(usersFile, filename);
   Reset(usersFile);
   {$i+} { Activate checkout of input/output errors}
   if (IoResult <> 0) then begin
      writeln('**** Error reading '+filename);
      halt(1)
   end;

   CreateEmptyQueue(Queue);

   while not EOF(usersFile) do
   begin
      { Read a line in the file and save it in different variables}
      ReadLn(usersFile, line);
      QItem.code := trim(copy(line,1,2));
      QItem.request:= line[4];
      QItem.param1 := trim(copy(line,5,10)); { trim removes blank spaces of the string}
                                         { copy(s, i, j) copies j characters of string s }
                                       { from position i }
      QItem.param2 := trim(copy(line,15,10));

      if not enqueue(QItem) then
      begin
         writeln('**** Queue is full ****');
         break;
      end;   

   end;

   Close(usersFile);

   RunTasks(Queue,Mng);

end;

procedure RunTasks(var Queue: tQueue, var Mng: tManager);
begin
   while not isEmptyQueue(Queue) do
   begin

      writeln('********************');
      case QItem.request of
        ///  Create
        'C': begin
           writeln(QItem.code,' ', QItem.request, ': center ', QItem.param1,' totalvoters ',QItem.param2);
           writeln;
           Create(QItem.param1,strToInt(QItem.param2),Mng);
        end;
        ///   New;
        'N': begin
           writeln(QItem.code,' ', QItem.request, ': center ', QItem.param1,' partyname ',QItem.param2);
           writeln;
        end;
        ///   Vote;
        'V': begin
           writeln(QItem.code,' ', QItem.request, ': center', QItem.param1,' partyname',QItem.param2);
           writeln;
        end;
         ///  Remove;
        'R': begin
           writeln(QItem.code,' ', QItem.request,': ');
           writeln;
        end;
         ///  Stats
        'S': begin
           writeln(QItem.code,' ', QItem.request,': ');
           writeln;
           Stats(Mng);

         end;
   end;
end;


{Main program}

begin
    if (paramCount>0) then
        readTasks(ParamStr(1))
    else
        readTasks('create.txt');
end.
