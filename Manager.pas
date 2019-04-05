unit Manager;

interface

  uses PartyList,CenterList,SharedTypes;

  type
    tManager = tListC;


  procedure createEmptyManager(var Mng: tManager);

  function InsertCenter(centerName: tCenterName; numVotes: tNumVotes; var Mng: tManager):boolean;

  function insertPartyInCenter(centerName: tCenterName; partyName: tPartyName; var Mng: tManager):boolean;

  function deleteCenters(var Mng: tManager):integer;

  procedure deleteManager(var Mng: tManager);

  procedure Stats(var Mng : tManager);

  function voteInCenter(centerName: tCenterName; partyName: tPartyName; var Mng: tManager):boolean;

implementation

procedure createEmptyManager(var Mng: tManager);
begin
  createEmptyCenterList(Mng);
end;

function InsertCenter(centerName: tCenterName; numVotes: tNumVotes; var Mng: tManager):boolean;
var
  newcenter: tItemC;
  newparty: tItem;
  temp: boolean;
begin

  with newcenter do begin
    newcenter.centername := centerName;
    newcenter.totalvoters := numVotes;
    newcenter.validvotes := 0;
    newcenter.partylist := NULL;
  end;

  temp:= insertItemC(newcenter,Mng);

  if temp then
  begin
    createEmptyList(getItemC(findItemC(centerName,Mng),Mng).partylist); (*Crea la lista de partidos vacía que depende del centro*)

    newparty.numvotes := 0;
    newparty.partyname := NULLVOTE;
    temp := (insertItem(newparty, getItemC(findItemC(centerName,Mng),Mng).partylist)); (*Inserta el partido de nulos*)

    newparty.partyname := BLANKVOTE;
    temp := temp and (insertItem(newparty, getItemC(findItemC(centerName,Mng),Mng).partylist)); (*Inserta el partido de blancos*)

    if not temp then (*Si la memoria dinámica estaba llena*)
    begin
      deleteList(getItemC(findItemC(centerName,Mng),Mng).partylist); (*Borra la lista de partidos*)
      deleteCenterAtPosition(getItemC(findItemC(centerName,Mng),Mng),Mng); (*Borra el centro ya que no se han podido crear NULLVOTE y BLANKVOTE*)
    end
  end;

  InsertCenter := temp;
end;

function insertPartyInCenter(centerName: tCenterName; partyName: tPartyName; var Mng: tManager):boolean;
var
posc: tPosC;
newparty: tItem;
begin
  posc := findItemC(centerName,Mng);
  if (posc = NULLC) then (*Tiene que ser null para la adicion de centro*)
  begin
    newparty.partyname:= partyName;
    newparty.numvotes := 0;
    insertPartyInCenter := insertItem(newparty, getItemC(posc, Mng).partylist );
  end
  else
    insertPartyInCenter:= FALSE;
end;

function deleteCenters(var Mng: tManager):integer;
var
temp: integer;
posc : tPosC;
begin
  if isEmptyCenterList(Mng) then deleteCenters:= 0
  else
  begin
    temp:= 0;
    while not isEmptyCenterList(Mng) and (getItemC(firstC(Mng),Mng).validvotes = 0) do begin (*Primero se borra el primer centro de la lista todas las veces que sea necesario*)
      deleteList(getItemC(firstC(Mng),Mng).partylist);
      deleteCenterAtPosition(firstC(Mng),Mng);
      temp:= temp+1;
    end;

    if not isEmptyCenterList(Mng) then (*Si la lista no se ha quedado vacía a base de eliminar el primer elemento repetidas veces, se continúa*)
      posc := firstC(Mng);

    while not isEmptyCenterList(Mng) and (nextC(posc,Mng) <> NULLC) do
      if getItemC(nextC(posc,Mng),Mng).validvotes = 0 then
      begin
        deleteList(getItemC(nextC(posc,Mng),Mng).partylist);
        deleteCenterAtPosition(nextC(posc,Mng), Mng);
        temp:= temp+1;
      end
      else
        posc:= nextC(posc,Mng);
    deleteCenters := temp;
  end;
end;

procedure deleteManager(var Mng: tManager);
begin
  while not isEmptyCenterList(Mng) do begin
    deleteList(getItemC(firstC(Mng),Mng).partylist);
    deleteCenterAtPosition(firstC(Mng),Mng);
  end;
end;

procedure Stats(var Mng : tManager);
var
pos            : tPosL;
posc           : tPosC;
item           : tItem; (*Both used to iterate around the list*)
participation  : tNumVotes; (*Keeps the number of votes that are not null*)
tempvalidvotes : tNumVotes;
center      : tItemC;
begin
  posc := firstC(Mng);
  writeln('LOL');
   while (posc <> NULLC) do begin
      writeln('LOLO');
      //writeln('Center ',center.centername);
      pos:= first(getItemC(posc,Mng).partylist);
      writeln('LOLOL');
      item := getItem(pos,getItemC(posc,Mng).partylist);
      writeln('Hasta');
         participation := item.numvotes;
         writeln('Stage 1');
      if center.validvotes = 0 then tempvalidvotes := 1  (*En el caso de que no haya ningun voto valido para evitar division por cero*)
      else tempvalidvotes := center.validvotes;
         writeln('Stage 2');
         writeln('Party ',item.partyname, ' numvotes ', item.numvotes:0, ' (', (item.numvotes*100/tempvalidvotes):2:2, '%)'); (*Prints BLANKVOTE*)

      pos:= next(pos,center.partylist);
      item := getItem(pos,center.partylist);
         participation := participation + item.numvotes;

         writeln('Party ',item.partyname, ' numvotes ', item.numvotes:0);(*Prints NULLVOTE*)

      pos:= next(pos,center.partylist);
         writeln('Stage 3');
         while pos<>NULL do begin
            item:= getItem(pos,center.partylist);
            writeln('Party ',item.partyname, ' numvotes ', item.numvotes:0, ' (', (item.numvotes*100/tempvalidvotes):2:2, '%)'); (*Prints all parties on the list*)
            participation := participation + item.numvotes;
            pos:= next(pos,center.partylist);
         end;
      writeln('Participation: ', participation:0, ' votes from ',center.totalvoters:0, ' voters (', (participation*100/center.totalvoters):2:2 ,'%)');

         writeln;
      posc := nextC(posc,Mng);
   end;
end;


function voteInCenter(centerName: tCenterName; partyName: tPartyName; var Mng: tManager):boolean;
var
cpos: tPosC;
ppos: tPosL;
nvotes: tNumVotes;
begin
  cpos := findItemC(centerName,Mng);
  ppos := findItem(partyName , getItemC(cpos,Mng).partylist);
   if (ppos = NULL) or (getItem(ppos,getItemC(cpos,Mng).partylist).partyname = NULLVOTE) then
  begin
    ppos := findItem(NULLVOTE, getItemC(cpos,Mng).partylist);
    nvotes := GetItem(ppos, getItemC(cpos,Mng).partylist).numvotes;
    nvotes := nvotes+1;
    UpdateVotes(nvotes, ppos, getItemC(cpos,Mng).partylist);
    voteInCenter := FALSE;
  end
  else
  begin
    updateValidVotesC((getItemC(cpos,Mng).validvotes + 1),cpos,Mng);
    nvotes := GetItem(ppos, getItemC(cpos,Mng).partylist).numvotes;
    nvotes := nvotes+1;
    UpdateVotes(nvotes, ppos, getItemC(cpos,Mng).partylist);
    voteInCenter := TRUE;
  end;
end;


end.
