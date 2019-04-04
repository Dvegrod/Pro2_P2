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
  if (posc <> NULLC) then
  begin
    newparty.partyname:= partyName;
    newparty.numvotes := 0;
    insertPartyInCenter := insertItem(newparty, GetItemC(posc, Mng).partylist );
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
    while not isEmptyCenterList(Mng) and (GetItemC(firstC(Mng),Mng).validvotes = 0) do begin (*Primero se borra el primer centro de la lista todas las veces que sea necesario*)
      deleteCenterAtPosition(firstC(Mng),Mng);
      temp:= temp+1;
    end;

    if not isEmptyCenterList(Mng) then (*Si la lista no se ha quedado vacía a base de eliminar el primer elemento repetidas veces, se continúa*)
      posc := firstC(Mng);
    
    while not isEmptyCenterList(Mng) and (nextC(posc,Mng) <> NULLC) do
      if GetItemC(nextC(posc,Mng),Mng).validvotes = 0 then
      begin
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
    deleteList(GetItemC(firstC(Mng),Mng).partylist);
    deleteCenterAtPosition(firstC(Mng),Mng);
  end;
end;

procedure showStats(Mng: tManager);
begin
  writeln('Manager Stats');
end;

function voteInCenter(centerName: tCenterName; partyName: tPartyName; var Mng: tManager):boolean;
var
cpos: tPosC;
ppos: tPosL;
nvotes: tNumVotes;
begin
  cpos := findItemC(centerName,Mng);
  ppos := findItem(partyName , GetItemC(cpos,Mng).partylist);
  if ppos = NULL then
  begin
    ppos := findItem(NULLVOTE, GetItemC(cpos,Mng).partylist);
    nvotes := GetItem(ppos, GetItemC(cpos,Mng).partylist).numvotes;
    nvotes := nvotes+1;
    UpdateVotes(nvotes, ppos, GetItemC(cpos,Mng).partylist);
    voteInCenter := FALSE;
  end
  else
  begin
    nvotes := GetItem(ppos, GetItemC(cpos,Mng).partylist).numvotes;
    nvotes := nvotes+1;
    UpdateVotes(nvotes, ppos, GetItemC(cpos,Mng).partylist);
    voteInCenter := TRUE;
  end;
end;


end.
