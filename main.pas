program main;

{
	TITLE: PROGRAMMING II LABS
	SUBTITLE: Practical 2
	AUTHOR 1: Carlos Torres Paz LOGIN 1: carlos.torres@udc.es
	AUTHOR 2: Daniel Sergio Vega Rodriguez LOGIN 2: d.s.vega@udc.es
	GROUP: 5.4
	DATE: 03/05/2019
}

uses sysutils,Manager,SharedTypes,RequestQueue;


procedure Create(cName: tCenterName; numVotes: tNumVotes; var Mng: tManager);
begin
   if InsertCenter(cName,numVotes,Mng) then (* Si fue posible la inserción *)
      writeln('* Create: center ',cName,' totalvoters ',numVotes:0)
   else writeln('+ Error: Create not possible');
end;

procedure New(cName: tCenterName; pName: tPartyName; var Mng: tManager);
begin
   if insertPartyInCenter(cName, pName,Mng) then (* Si fue posible la inserción *)
      writeln('* New: center ',cName, ' party ',pName)
   else writeln('+ Error: New not possible');
end;

procedure Vote(cName : tCenterName; pName : tPartyName; var Mng: tManager);
begin
   if voteInCenter(cName, pName, Mng) then
      writeln('* Vote: center ',cName,' party ',pName)
   else
      begin
         write('+ Error: Vote not possible.');  (*En caso de no encontrar el partido o el centro da error,
                                                 en el primer caso error el voto se suma a NULLVOTES *)
         if voteInCenter(cName,NULLVOTE, Mng) then
            writeln(' Party ',pName, ' not found in center ',cName, '. NULLVOTE')
         else writeln;
      end;
end;

procedure Remove(var Mng : tManager);
begin
   if deleteCenters(Mng) = 0 then writeln('* Remove: No centers removed');
end;

procedure ShowStats(var Mng: tManager);
begin
   Stats(Mng);
end;


{----------------------------------------}
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
QItem  : tItemQ;   (* Variable que guarda un nodo de la cola para la extracción de sus datos*)
   Mng : tManager; (* La multilista que se usará a continuación*)
begin
   CreateEmptyManager(Mng); (* Inicialización *)
   while not isEmptyQueue(Queue) do  (* Las operaciones acaban cuando la cola está vacía *)
   begin
      QItem:= front(Queue);
      writeln('********************');
      with QItem do begin (* Case que discrimina cada comando con su correspondiente subrutina y formato *)
         case request of
           ///  Create
           'C': begin
              writeln(code,' ', request, ': center ', param1,' totalvoters ',param2);
              writeln;
              Create(param1,strToInt(param2),Mng);
           end;
           ///   New
           'N': begin
              writeln(code,' ', request, ': center ', param1,' party ',param2);
              writeln;
              new(param1,param2,Mng);
           end;
           ///   Vote
           'V': begin
              writeln(code,' ', request, ': center', param1,' party',param2);
              writeln;
              vote(param1,param2,Mng);
           end;
           ///  Remove
           'R': begin
              writeln(code,' ', request,': ');
              writeln;
              Remove(Mng);
           end;
           ///  Stats
           'S': begin
              writeln(code,' ', request,': ');
              writeln;
              Stats(Mng);
           end;
           otherwise writeln(' + Not a valid request'); (* En caso de algún error con el input *)
         end;
      end;
      dequeue(Queue); (* Borrado del comienzo de la cola (la operación ya ejecutada) *)
   end;
   deleteManager(Mng); (* Borrado de la memoria ocupada por la multilista *)
end;


{Main program}

begin
    if (paramCount>0) then
        readTasks(ParamStr(1))
    else
        readTasks('create.txt');
end.
