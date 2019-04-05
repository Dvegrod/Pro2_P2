unit Manager;

interface

  uses PartyList,CenterList,SharedTypes;

  type
    tManager = tListC;

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
    centername := centerName;
    totalvoters := numVotes;
    validvotes := 0;
    partylist := NULL;
  end;
  temp := (insertItemC(newcenter, Mng));

  if temp then
  begin
    createEmptyList(newcenter.partylist);

    newparty.numvotes := 0;
    newparty.partyname := NULLVOTE;
    temp := (insertItem(newparty, newcenter.partylist));

    newparty.partyname := BLANKVOTE;
    temp := temp and (insertItem(newparty, newcenter.partylist));
    
    if not temp then
      deleteCenterAtPosition(findItemC(centerName,Mng),Mng); (*Si se ha podido insertar el centro pero no los partidos NULLVOTE o BLANKVOTE*)
      (*Se elimina el centro insertado, ya que no tiene sentido un centro sin su lista de partidos.*)
  end;

  InsertCenter:= temp;
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

procedure Stats(Mng : tManager);
var
pos               : tPosL;
posc              : tPosC;
item              : tItem; (*Both used to iterate around the list*)
participation     : tNumVotes; (*Keeps the number of votes that are not null*)
tempvalidvotes    : tNumVotes;
begin
  posc := firstC(Mng);
   while (posc <> NULLC) do begin
      with getItemC(posc,Mng) do begin
         writeln('Center ',centerName);
         pos:= first(partylist);
         item := getItem(pos,partylist);
         participation := item.numvotes;

         if validvotes = 0 then tempvalidvotes := 1  (*En el caso de que no haya ningun voto valido para evitar division por cero*)
         else tempvalidvotes := validvotes;

         writeln('Party ',item.partyname, ' numvotes ', item.numvotes:0, ' (', (item.numvotes*100/tempvalidvotes):2:2, '%)'); (*Prints BLANKVOTE*)

         pos:= next(pos,partylist);
         item := getItem(pos,partylist);
         participation := participation + item.numvotes;

         writeln('Party ',item.partyname, ' numvotes ', item.numvotes:0);(*Prints NULLVOTE*)

         pos:= next(pos,partylist);

         while pos<>NULL do begin
            item:= getItem(pos,partylist);
            writeln('Party ',item.partyname, ' numvotes ', item.numvotes:0, ' (', (item.numvotes*100/tempvalidvotes):2:2, '%)'); (*Prints all parties on the list*)
            participation := participation + item.numvotes;
            pos:= next(pos,partylist);
         end;
         writeln('Participation: ', participation:0, ' votes from ',totalvoters:0, ' voters (', (participation*100/totalvoters):2:2 ,'%)');
      end;
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
