program main;

uses sysutils,Manager,SharedTypes,RequestQueue;


procedure Create(cName: tCenterName; numVotes: tNumVotes; var Mng: tManager);
begin
   if InsertCenter(cName,numVotes,Mng) then
      writeln('* Create: center ',cName,' totalvoters ',numVotes:0)
   else writeln('+ Error: Create not possible');
end;

procedure New(cName: tCenterName; pName: tPartyName; var Mng: tManager);
begin
   if insertPartyInCenter(cName, pName,Mng) then
      writeln('* New: center ',cName, ' party ',pName)
   else writeln('+ Error: New not possible');
end;

procedure Vote(cName : tCenterName; pName : tPartyName; var Mng: tManager);
begin
   if voteInCenter(cName, pName, Mng) then
      writeln('* Vote: center ',cName,' party ',pName)
   else
      begin
         write('+ Error: Vote not possible.');
         if voteInCenter(cName,NULLVOTE, Mng) then
            writeln(' Party ',pName, ' not found in center ',cName, '. NULLVOTE')
         else writeln;
      end;
end;

procedure RunTasks(var Queue: tQueue); forward;

procedure readTasks(filename:string);

VAR
   usersFile              : text;
   line                   : string;
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

      if not enqueue(QItem,Queue) then
      begin
         writeln('**** Queue is full ****');
         break;
      end;

   end;

   Close(usersFile);

   RunTasks(Queue);

end;

procedure RunTasks(var Queue: tQueue);
var
QItem  : tItemQ;
   Mng : tManager;
begin
   CreateEmptyManager(Mng);
   while not isEmptyQueue(Queue) do
   begin
      QItem:= front(Queue);

      writeln('********************');
      case QItem.request of
        ///  Create
        'C': begin
           writeln(QItem.code,' ', QItem.request, ': center ', QItem.param1,' totalvoters ',QItem.param2);
           writeln;
           Create(QItem.param1,strToInt(QItem.param2),Mng);
        end;
        ///   New
        'N': begin
           writeln(QItem.code,' ', QItem.request, ': center ', QItem.param1,' partyname ',QItem.param2);
           writeln;
        end;
        ///   Vote
        'V': begin
           writeln(QItem.code,' ', QItem.request, ': center', QItem.param1,' partyname',QItem.param2);
           writeln;
        end;
         ///  Remove
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
      dequeue(Queue);
   end;
end;


{Main program}

begin
    if (paramCount>0) then
        readTasks(ParamStr(1))
    else
        readTasks('create.txt');
end.
