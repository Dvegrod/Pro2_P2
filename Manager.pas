unit Manager;

{
	TITLE: PROGRAMMING II LABS
	SUBTITLE: Practical 2
	AUTHOR 1: Carlos Torres Paz LOGIN 1: carlos.torres@udc.es
	AUTHOR 2: Daniel Sergio Vega Rodriguez LOGIN 2: d.s.vega@udc.es
	GROUP: 5.4
	DATE: 03/05/2019
}

interface

  uses PartyList,CenterList,SharedTypes;

  type
    tManager = tListC;

(* Manager hace referencia a una multilista ,es decir, una variable tipo tManager*)
  procedure createEmptyManager(var Mng: tManager);
(*
 Objetivo: inicializa una multilista.
 Entrada: una variable tipo multilista.
 Salida: la entrada inicializada y vacía.
 *)
{ PRECONDICION GENERAL: La variable de tipo tManager debe estar inicializada a la hora de ser usada por las siguientes funciones:}
  function insertCenter(cName: tCenterName; numVotes: tNumVotes; var Mng: tManager):boolean;
(*
 Objetivo: inserta un nuevo centro en el manager determinado con un numero de votantes determinado y los "partidos" B y N con sus votos a 0.
 Entradas: un nombre de centro, un numero de votos y el manager.
 Salidas: el manager con el nuevo centro insertado en la posición correspondiente y un booleano que es TRUE solo si la operación se completó.
 Postcondición: Las posiciones de los elementos de la lista posteriores al insertado pueden cambiar de valor. Si había un centro idéntico en la lista
 no se modifica la lista y la operación devuelve FALSE.
 *)
  function insertPartyInCenter(cName: tCenterName; pName: tPartyName; var Mng: tManager):boolean;
(*
 Objetivo: inserta un partido en la lista de partidos de un centro (en el manager especificado) con sus votos a 0.
 Entradas: el nombre del centro en el que se inserta el partido, el nombre del nuevo partido, el manager en el que se opera.
 Salidas: el manager modificado y un booleano que es TRUE si la operación ha sido posible.
 Precondición: el centro debe ser válido.
 Postcondición: las posiciones de los partidos del centro pueden haber cambiado, si el partido a introducir ya existe la función devuelve FALSE.
 *)
  function deleteCenters(var Mng: tManager):integer;
(*
 Objetivo: elimina los centros electorales cuyo número de votos válidos es 0 y sus respectivas listas de partidos.
 Entrada: el manager en el que se va a ejecutar la operación.
 Salida: el manager modificado y un entero cuyo valor es el número de partidos eliminados.
 *)
  procedure deleteManager(var Mng: tManager);
(*
 Objetivo: elimina todos los elementos de la multilista (manager) y sus respectivas estructuras subordinadas.
 Entradas: el manager que va a ser vaciado.
 Salidas: el manager vacío.
 *)
  procedure ShowStats(var Mng : tManager);
(*
 Objetivo: muestra una serie de estadísticas de votación y participación (Número, y porcentajes salvo en NULOS) de cada uno de los centros por separado.
 Entradas: la multilista (manager).
 Salidas: texto por pantalla
 (El manager se pasa por referencia por eficiencia de la memoria, no se modifica en ningún momento)).
 Poscondición: si la multilista está vacía el procedimiento emitirá un mensaje de error por pantalla.
 *)
  function voteInCenter(cName: tCenterName; pName: tPartyName; var Mng: tManager):boolean;
(*
 Objetivo: incrementa en uno el número de votos del partido especificado en el centro especificado.
 Entradas: el nombre del centro, el nombre del partido, la multilista.
 Salidas: la multilista modificada y un booleano que informa de la validez del voto.
 Postcondición: si el partido no existe en el centro o si el centro no es válido devuelve FALSE.
 *)

implementation


procedure createEmptyManager(var Mng: tManager);
begin
  createEmptyListC(Mng);
end;

function insertCenter(cName: tCenterName; numVotes: tNumVotes; var Mng: tManager):boolean;
var
  newcenter: tItemC;
  newparty: tItem;
  newpartylist: tList;  (* Variables dedicadas a guardar temporalmente las listas y elementos con los que se opera *)
  temp: boolean;        (* Boolean temporal que controla el comportamiento de la función y su resultado *)

begin
  if findItemC(cName,Mng) = NULLC then begin (*Comprueba si el centro ya existe. Si ya existe, no hace nada y devuelve FALSE*)  
    createEmptyList(newpartylist);

    with newparty do begin    (* Partido B *)
      partyname:= BLANKVOTE;
      numvotes:= 0;
    end;

    temp:= InsertItem(newparty,newpartylist);
    newparty.partyname:= NULLVOTE; (* Partido N *)
    temp:= temp and InsertItem(newparty,newpartylist);

    if temp then (*Si se han insertado correctamente los partidos en la lista*)
    with newcenter do begin (* Creacion del centro nuevo *)
      centername := cName;
      totalvoters := numVotes;
      validvotes := 0;
      partylist := newpartylist;
    end;

    temp:= temp and insertItemC(newcenter,Mng);

    if not temp then (*Si la lista de centros estaba llena*)
        while not isEmptyList(newpartylist) do
           deleteAtPosition(first(newpartylist),newpartylist); (*Borra la lista de partidos*)
    insertCenter := temp; (* temp es TRUE si y sólo si la operación se completó*)
  end else
    insertCenter:=false;
end;


function insertPartyInCenter(cName : tCenterName; pName : tPartyName; var Mng : tManager): boolean;
var
   posc        : tPosC; (* Variable para conservar la posición del centro en el que se va a operar *)
   newlist     : tList; (* Puntero con el que se trabaja la lista *)
   newparty    : tItem; (* Nuevo nodo de lista de partidos *)

begin
  posc := findItemC(cName,Mng);
  if (posc <> NULLC) then (*Comprueba si existe el centro especificado*)
  begin
    newlist := getItemC(findItemC(cName,Mng),Mng).partylist; (* Se obtiene el puntero al primer elemento de la lista de partidos del centro *)
    if findItem(pName, newlist) = NULL then begin (*Comprueba que el partido no exista ya en la lista*)
    with newparty do begin (* Construcción del nuevo partido *)
       partyname := pName;
       numvotes := 0;
    end;
    if insertItem(newparty,newlist) then begin (*Comprueba que haya memoria dinámica disponible*)
       updateListC(newlist, posc, Mng);(* Actualización del puntero para prevenir errores *)
       insertPartyInCenter := true;
    end else
       insertPartyInCenter := false;
    end else
      insertPartyInCenter:= false;
  end
  else
    insertPartyInCenter:= false;
end;

procedure deletePartyList(cpos: tPosC; var Mng: tManager); (*Función auxiliar para el DeleteCenters*)
var
   plist : tPosL;
begin
   plist := getItemC(cpos,Mng).partylist;
   while not isEmptyList(plist) do (*Eliminación secuencial de los elementos*)
      deleteAtPosition(first(plist),plist);
   updateListC(plist,cpos,Mng);(* Actualización del puntero para prevenir errores *)
end;

function deleteCenters(var Mng: tManager):integer;
var
temp: integer;           (* Variable que guarda el numero de centros eliminados *)
posc,preposc : tPosC;    (* Variables posicion para iterar en la multilista*)
tempcenter   : tItemC;   (* Variable que guarda el centro en el que esta situada la iteracion *)
begin
  if isEmptyListC(Mng) then deleteCenters:= 0
  else
  begin
    temp:= 0;
       tempcenter:= getItemC(lastC(Mng),Mng);
       while (not isEmptyListC(Mng) and (tempcenter.validvotes = 0)) do begin (*Primero se borra el último centro de la lista todas las veces que sea necesario*)
          deletePartyList(lastC(Mng),Mng); (*Borra su lista de partidos*)
          writeln('* Remove: center ', tempcenter.centername);
          deleteAtPositionC(lastC(Mng),Mng); (*Y luego borra el centro*)
          temp:= temp+1;
          tempcenter:= getItemC(lastC(Mng),Mng)
       end;

    if not isEmptyListC(Mng) then begin (*Si la lista no se ha quedado vacía a base de eliminar el último elemento repetidas veces, se continúa*)
      posc := lastC(Mng);
      preposc := previousC(posc,Mng);
    end;

    while not isEmptyListC(Mng) and (preposc <> NULLC) do begin  
    (* Eliminacion de los elementos anteriores al ultimo que cumplen con la condicion de eliminacion*)
       tempcenter:= getItemC(preposc,Mng);
       with tempcenter do begin
         if validvotes = 0 then
         begin (* Proceso de eliminacion del centro *)
            deletePartyList(preposc,Mng);
            writeln('* Remove: center ', centername);
            deleteAtPositionC(preposc, Mng);
            temp:= temp+1;
         end
         else
            posc:= previousC(posc,Mng);
         preposc := previousC(posc,Mng);
       end;
      end;
    deleteCenters := temp;
  end;
end;
(*Aquí empezamos los borrados por el final por motivos de eficiencia, ya que los centros son una lista estática y las eliminaciones
son más eficientes por el final. Aun así, no se ha entrado dentro del TAD CenterList en ningún momento, por lo que serviría sin problemas
en el caso de que la lista de centros pasase a ser dinámica*)


procedure deleteManager(var Mng: tManager);
begin
  while not isEmptyListC(Mng) do begin
    deletePartyList(lastC(Mng),Mng);
    deleteAtPositionC(lastC(Mng),Mng);
  end;
end;

procedure ShowStats(Mng : tManager);
var
pos               : tPosL;
posc              : tPosC;
item              : tItem; (*Las variables pos se usan para guardar una posiciones de referencia en la multilista y item como valor temporal*)
participation     : tNumVotes; (*Guarda la acumulación de votos en un centro*)
tempvalidvotes    : tNumVotes; (*Variable necesaria debido a la posibilidad de que los votos válidos sean 0*)
begin
  if not isEmptyListC(Mng) then begin
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
  end else writeln('+ Error: ShowStats not possible'); (* En caso de que la lista esté vacía *)
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
        if pname <> NULLVOTE then updateValidVotesC((getItemC(cpos,Mng).validvotes + 1),cpos,Mng); (*Comprueba si el voto es nulo, en cuyo caso no actualiza los votos válidos*)
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

end.
