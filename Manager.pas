unit Manager;

interface

  uses PartyList,CenterList,SharedTypes;

  type
    tManager = tListC;


  procedure createEmptyManager(var Mng: tManager);
(*
 Objetivo: inicializa un manager vacío.
 Entrada: una variable tipo multilista.
 Salida: la entrada inicializada y vacía.
 *)
{ PRECONDICION GENERAL: La variable de tipo tManager debe estar inicializada a la hora de ser usada por las siguientes funciones:}
  function InsertCenter(cName: tCenterName; numVotes: tNumVotes; var Mng: tManager):boolean;
(*
 Objetivo: inserta un nuevo centro en el manager determinado con un numero de votos determinado.
 Entradas: un nombre de centro, un numero de votos y el manager.
 Salidas: el manager con el nuevo centro insertado en la posición correspondiente y un booleano que es TRUE solo si la operación se completó.
 Postcondición: Las posiciones de los elementos de la lista posteriores al insertado pueden cambiar de valor. Si habia un centro idéntico en la lista
 ambos serán conservados.
 *)
  function insertPartyInCenter(cName: tCenterName; pName: tPartyName; var Mng: tManager):boolean;
(*
 Objetivo: inserta un partido en la lista de partidos de un centro (en el manager especificado).
 Entradas: el nombre del centro en el que se inserta el partido, el nombre del nuevo partido, el manager en el que se opera.
 Salidas: el manager modificado y un booleano que es TRUE si la operación ha sido posible.
 Precondición: el centro debe ser válido.
 Postcondición: las posiciones de los partidos del centro pueden haber cambiado.
 *)
  function deleteCenters(var Mng: tManager):integer;
(*
 Objetivo: elimina los centros electorales cuyo número de votos válidos es 0 y sus respectivas listas de partidos.
 Entrada: el manager en el que se va a ejecutar la operación.
 Salida: el manager modificado y un entero cuyo valor es el número de partidos eliminados.
 *)
  procedure deleteManager(var Mng: tManager);
(*
 Objetivo: elimina todos los elementos de la multilista (manager).
 Entradas: el manager que va a ser vaciado.
 Salidas: el manager vacío.
 *)
  procedure Stats(var Mng : tManager);
(*
 Objetivo: muestra una serie de estadísticas de votación y participación de cada uno de los centros.
 Entradas: la multilista (manager).
 *)
  function voteInCenter(cName: tCenterName; pName: tPartyName; var Mng: tManager):boolean;
(*
 Objetivo: incrementa en uno el número de votos del partido especificado en el centro especificado.
 Entradas: el nombre del centro, el nombre del partido, la multilista.
 Salidas: la multilista modificada y un booleano que informa de la validez del voto.
 Precondición: el centro electoral es válido.
 Postcondición: si el partido no existe en el centro designado, se actualiza el número de votos nulos.
 *)

implementation

procedure deletePartyList(cName: tCenterName;var Mng: tManager); forward;

procedure createEmptyManager(var Mng: tManager);
begin
  createEmptyCenterList(Mng);
end;

function InsertCenter(cName: tCenterName; numVotes: tNumVotes; var Mng: tManager):boolean;
var
  newcenter: tItemC;
  newparty: tItem;
  newpartylist: tList;
  temp: boolean;

begin
  createEmptyList(newpartylist);

  with newparty do begin
    partyname:= BLANKVOTE;
    numvotes:= 0;
  end;

  temp:= InsertItem(newparty,newpartylist);
  newparty.partyname:= NULLVOTE;
  temp:= temp and InsertItem(newparty,newpartylist);

  if temp then
  with newcenter do begin
    centername := cName;
    totalvoters := numVotes;
    validvotes := 0;
    partylist := newpartylist;
  end;

  temp:= temp and insertItemC(newcenter,Mng);

  if not temp then (*Si la lista de centros estaba llena*)
      while not isEmptyList(newpartylist) do
         deleteAtPosition(first(newpartylist),newpartylist); (*Borra la lista de partidos*)
  InsertCenter := temp; (* temp es TRUE si y sólo si la operación se completó*)
end;

function insertPartyInCenter(cName : tCenterName; pName : tPartyName; var Mng : tManager): boolean;
var
   posc        : tPosC;
   newlist     : tList;
   newparty    : tItem;
   temp: boolean;

begin
  posc := findItemC(cName,Mng);
  if (posc <> NULLC) then
  begin
    newlist := getItemC(findItemC(cName,Mng),Mng).partylist;
    with newparty do begin
       partyname := pName;
       numvotes := 0;
    end;
    temp := insertItem(newparty,newlist); (*Comprueba que haya memoria dinámica disponible*)
    if temp then
      updateListC(newlist, posc, Mng);
    insertPartyInCenter := temp;
  end
  else
    insertPartyInCenter:= false;
end;


procedure deletePartyListatCPosition(cpos: tPosC; var Mng: tManager); (*Función auxiliar para el DeleteCenters*)
var
   plist : tPosL;
begin
   plist := getItemC(cpos,Mng).partylist;
   while not isEmptyList(plist) do
      deleteAtPosition(first(plist),plist);
   updateListC(plist,cpos,Mng);
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
    posc := lastC(Mng);
    while (posc >= firstC(Mng)) do
       with getItemC(posc,Mng) do begin
          if validvotes = 0 then begin
             deletePartyListatCPosition(posc,Mng);
             deleteCenterAtPosition(posc,Mng);
             writeln('* Remove: center ',centername);
             temp := temp + 1;
             posc := previousC(posc,Mng);
          end
          else
             posc := previousC(posc,Mng);
       end;
    deleteCenters := temp;
  end;
end;

{-O-}


procedure deleteManager(var Mng: tManager);
begin
  while not isEmptyCenterList(Mng) do begin
    deletePartyListatCPosition(lastC(Mng),Mng);
    deleteCenterAtPosition(lastC(Mng),Mng);
  end;
end;

procedure Stats(var Mng : tManager);
var
pos               : tPosL;
posc              : tPosC;
item              : tItem; (*Las variables pos se usan para guardar una posiciones de referencia en la multilista y item como valor temporal*)
participation     : tNumVotes; (*Guarda la acumulación de votos en un centro*)
tempvalidvotes    : tNumVotes; (*Variable necesaria debido a la posibilidad de que los votos válidos sean 0*)
begin
  if not isEmptyCenterList(Mng) then begin
     posc := firstC(Mng);
     while (posc <> NULLC) do begin  (* Bucle hasta final de lista de centros *)
        with getItemC(posc,Mng) do begin
           writeln('Center ',centername);
           if validvotes = 0 then tempvalidvotes := 1  (* Protección de la división en el caso de que validvotes sea 0 *)
           else tempvalidvotes := validvotes;
           //-/\-Preámbulos-/\------\/-Partidos-del-centro-\/----------------
           pos:= first(partylist);
           while pos<>NULL do begin (* Bucle hasta final de lista de partidos *)
              item:= getItem(pos,partylist);
              if (item.partyname <> NULLVOTE) then (*Condicional que detecta NULLVOTES para no mostrar porcentaje en el mismo*)
                 writeln('Party ',item.partyname, ' numvotes ', item.numvotes:0, ' (',item.numvotes*100/tempvalidvotes:2:2, '%)') (*Prints all parties on the list*)
              else begin
                 writeln('Party ',item.partyname, ' numvotes ', item.numvotes:0);
                 participation := item.numvotes;
              end;
              pos:= next(pos,partylist);
           end; (*Linea final de participación \/--\/ *)
           participation := participation +  validvotes; (* El valor previo de participation es el valor de votos nulos *)
           writeln('Participation: ', participation:0, ' votes from ',totalvoters:0, ' voters (', (participation*100/totalvoters):2:2 ,'%)');
        end;
        writeln; (* <-- Por formato  \/ Siguiente centro \/ *)
        posc := nextC(posc,Mng);
     end;
  end else writeln('+ Error: Stats not possible'); (* En caso de que la lista esté vacía *)
end;

function voteInCenter(cName: tCenterName; pName: tPartyName; var Mng: tManager):boolean;
var
cpos: tPosC;
ppos: tPosL; (* Variables pos para usar como localizadoras en la multilista *)
nvotes: tNumVotes; (* Número para usar temporalmente en calculos *)
begin
  cpos := findItemC(cName,Mng);
  if (cpos <> NULLC) then (*Cierto si encontró el centro *)
    begin
      ppos := findItem(pName , getItemC(cpos,Mng).partylist);
      if (ppos <> NULL) then  (*Cierto si encontró el partido en el centro *)
      begin
        if pname <> NULLVOTE then updateValidVotesC((getItemC(cpos,Mng).validvotes + 1),cpos,Mng); (*Fitro de votos nulos*)
        nvotes := GetItem(ppos, getItemC(cpos,Mng).partylist).numvotes;
        nvotes := nvotes+1;
        UpdateVotes(nvotes, ppos, getItemC(cpos,Mng).partylist); (* Adición del voto (Extracción-Suma-Actualización) *)
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
   if centerpos <> NULLC then begin
      plist := getItemC(centerpos,Mng).partylist;
      while not isEmptyList(plist) do
         deleteAtPosition(first(plist),plist);
      updateListC(plist,centerpos,Mng);
   end;
end;

end.
