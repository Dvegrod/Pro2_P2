unit Manager;

interface

  uses PartyList,CenterList,SharedTypes;

  type
    tManager = tCenterList;

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

    newparty.numvotes := 0
    newparty.partyname := NULLVOTE;
    temp := (insertItem(newparty, newcenter.partylist));

    newparty.partyname := BLANKVOTE;
    temp := (insertItem(newparty, newcenter.partylist));
    
    if not temp then
      deleteCenterAtPosition(findItemC(centerName,Mng),Mng); (*Si se ha podido insertar el centro pero no los partidos NULLVOTE o BLANKVOTE*)
      (*Se elimina el centro insertado, ya que no tiene sentido un centro sin su lista de partidos.*)
  end;

  InsertCenter:= temp;
end;

end.
