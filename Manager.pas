unit Manager;

interface

  uses PartyList,CenterList,SharedTypes;

  type
    tManager = tListC;


  procedure createEmptyManager(var Mng: tManager);

  function InsertCenter(cName: tCenterName; numVotes: tNumVotes; var Mng: tManager):boolean;

  function insertPartyInCenter(cName: tCenterName; pName: tPartyName; var Mng: tManager):boolean;

  function deleteCenters(var Mng: tManager):integer;

  procedure deleteManager(var Mng: tManager);

  procedure Stats(var Mng : tManager);

  function voteInCenter(cName: tCenterName; pName: tPartyName; var Mng: tManager):boolean;

implementation

procedure deletePartyList(cName: tCenterName;var Mng: tManager); forward;

procedure createEmptyManager(var Mng: tManager);
begin
  createEmptyCenterList(Mng);
end;

function InsertCenter(cName: tCenterName; numVotes: tNumVotes; var Mng: tManager):boolean;
var
  newcenter: tItemC;
  temp: boolean;
begin

  with newcenter do begin
    centername := cName;
    totalvoters := numVotes;
    validvotes := 0;
    createEmptyList(partylist);
  end;
  temp:= insertItemC(newcenter,Mng);

  if temp then
  begin
    { createEmptyList(getItemC(findItemC(cName,Mng),Mng).partylist); (*Crea la lista de partidos vacía que depende del centro*)}

    temp := (insertPartyInCenter(cName,NULLVOTE,Mng)); (*Inserta el partido de nulos*)

    temp := temp and (insertPartyInCenter(cName,BLANKVOTE,Mng)); (*Inserta el partido de blancos*)

    if not temp then (*Si la memoria dinámica estaba llena*)
    begin
      deletePartyList(cName,Mng); (*Borra la lista de partidos*)
      deleteCenterAtPosition(findItemC(cName,Mng),Mng); (*Borra el centro ya que no se han podido crear NULLVOTE y BLANKVOTE*)
    end
  end;
  InsertCenter := temp;
end;

function insertPartyInCenter(cName: tCenterName; pName: tPartyName; var Mng: tManager):boolean;
var
posc        : tPosC;
newlist     : tList;
newparty    : tItem;
begin
  posc := findItemC(cName,Mng);
  if (posc <> NULLC) then
  begin
    newlist := getItemC(findItemC(cName,Mng),Mng).partylist;
    with newparty do begin
       partyname := pName;
       numvotes := 0;
    end;
    insertItem(newparty,newlist);
    updateListC(newlist, posc, Mng);
    insertPartyInCenter := true;
  end
  else
    insertPartyInCenter:= false;
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
      deletePartyList(getItemC(firstC(Mng),Mng).centername,Mng);
      deleteCenterAtPosition(firstC(Mng),Mng);
      temp:= temp+1;
    end;

    if not isEmptyCenterList(Mng) then (*Si la lista no se ha quedado vacía a base de eliminar el primer elemento repetidas veces, se continúa*)
      posc := firstC(Mng);

    while not isEmptyCenterList(Mng) and (nextC(posc,Mng) <> NULLC) do
      if getItemC(nextC(posc,Mng),Mng).validvotes = 0 then
      begin
        deletePartyList(getItemC(nextC(posc,Mng),Mng).centername,Mng);
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
    deletePartyList(getItemC(firstC(Mng),Mng).centername,Mng);
    deleteCenterAtPosition(firstC(Mng),Mng);
  end;
end;

procedure Stats(var Mng : tManager);
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
         writeln('Center ',centername);
         //---BLANKVOTE---------------------------------------------
         pos:= findItem(BLANKVOTE,partylist);
         item := getItem(pos,partylist);

         participation := item.numvotes;
         if validvotes = 0 then tempvalidvotes := 1  (*En el caso de que no haya ningun voto valido para evitar division por cero*)
         else tempvalidvotes := validvotes;

         writeln('Party ',item.partyname, ' numvotes ', item.numvotes:0, ' (', (item.numvotes*100/tempvalidvotes):2:2, '%)'); (*Prints BLANKVOTE*)
         //---NULLVOTE----------------------------------------------
         pos:= findItem(NULLVOTE,partylist);
         item := getItem(pos,partylist);

         participation := participation + item.numvotes;

         writeln('Party ',item.partyname, ' numvotes ', item.numvotes:0);(*Prints NULLVOTE*)
         //---PARTIES-----------------------------------------------
         pos:= first(partylist);
         while pos<>NULL do begin
            item:= getItem(pos,partylist);
            if (item.partyname <> NULLVOTE) and (item.partyname <> BLANKVOTE) then begin
               writeln('Party ',item.partyname, ' numvotes ', item.numvotes:0, ' (', (item.numvotes*100/tempvalidvotes):2:2, '%)'); (*Prints all parties on the list*)
               participation := participation + item.numvotes;
            end;
            pos:= next(pos,partylist);
         end;
         writeln('Participation: ', participation:0, ' votes from ',totalvoters:0, ' voters (', (participation*100/totalvoters):2:2 ,'%)');
      end;
      writeln;
      posc := nextC(posc,Mng);
   end;
end;

function voteInCenter(cName: tCenterName; pName: tPartyName; var Mng: tManager):boolean;
var
cpos: tPosC;
ppos: tPosL;
nvotes: tNumVotes;
begin
  cpos := findItemC(cName,Mng);
  if (cpos <> NULLC) then
    begin
      ppos := findItem(pName , getItemC(cpos,Mng).partylist);
      if (ppos <> NULL) then
      begin
        updateValidVotesC((getItemC(cpos,Mng).validvotes + 1),cpos,Mng);
        nvotes := GetItem(ppos, getItemC(cpos,Mng).partylist).numvotes;
        nvotes := nvotes+1;
        UpdateVotes(nvotes, ppos, getItemC(cpos,Mng).partylist);
        voteInCenter := true;
      end
      else
        voteInCenter := false;
    end
  else
  begin
    voteInCenter:= false;
  end;
end;

procedure deletePartyList(cName: tCenterName;var Mng: tManager);
var
   centerpos: tPosC;
   plist: tPosL;
begin
   centerpos:= findItemC(cName,Mng);
   if centerpos <> NULLC then
      plist := getItemC(centerpos,Mng).partylist;
   while not isEmptyList(plist) do
      deleteAtPosition(first(plist),plist);
end;

end.
