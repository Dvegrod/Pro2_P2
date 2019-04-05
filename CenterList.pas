unit CenterList;

{
	TITLE: PROGRAMMING II LABS
	SUBTITLE: Practical 1
	AUTHOR 1: Carlos Torres Paz LOGIN 1: carlos.torres@udc.es
	AUTHOR 2: Daniel Sergio Vega Rodriguez LOGIN 2: d.s.vega@udc.es
	GROUP: 5.4
	DATE: 29/03/2019
}

interface
  Uses SharedTypes, PartyList;

	const
		MAXC = 25 ; (*tamaño máximo del array*)
		NULLC = 0;

	type
		tPosC = NULLC..MAXC;

    tItemC = record
                centername  : tCenterName;
                totalvoters,validvotes  : tNumVotes;
                partylist   : tList;
             end;

		tListC = record
					data : array [1..MAXC] of tItemC;
          lst  : tPosC;
			end;

	procedure createEmptyCenterList(var L: tListC);
    (*  Objetivo: Crea una lista vacía
        Entradas: La variable donde se va a almacenar la lista
        Salidas: La lista Vacía
        Postcondición: La lista queda inicializada y no contiene elementos  *)
	function isEmptyCenterList(L:tListC): boolean;
    (*  Objetivo: Comprueba si la lista está vacía
        Entrada: Una lista
        Salida: Un boolean TRUE si está vacía y FALSE si no lo está *)
	function firstC(L:tListC):tPosC;
    (*  Objetivo: Devuelve la posición del primer elemento de la lista
        Entrada: Una lista
        Salida: La posición del primer elemento
        Precondición: La lista no está vacía    *)
	function lastC(L:tListC):tPosC;
    (*  Objetivo: Devuelve la posición del último elemento de la lista
        Entrada: Una Lista
        Salida: La posición del último elemento
        Precondición: La lista no está vacía    *)
	function nextC(p:tPosC; L:tListC):tPosC;
    (*  Objetivo: Devuelve la posición en la lista del elemento siguiente al indicado
        Entrada: Una Lista
        Salida: La posición del elemento siguiente
        Precondición: La posición indicada es una posición válida*)
	function previousC(p:tPosC; L:tListC):tPosC;
	(*	Objetivo: Devuelve la posición en la lista del elemento anterior al indicado
		Entrada: Una lista
		Salida: La posición del elemento anterior
		Precondición: La posición indicada es una posición válida*)
	function insertItemC(d:tItemC; var L : tListC): boolean;
	(*	Objetivo: Inserta un elemento en la lista en la posicion que le corresponde
   por orden del alfabeto (nombre del centro)
		Entrada: Un elemento a insertar, una posición y una lista
		Salida: La lista con el elemento insertado y un boolean TRUE si se ha insertado correctamente y un FALSE en caso contrario
		Postcondición: Las posiciones de los elementos de la lista posteriores al insertado pueden cambiar de valor*)
	procedure deleteCenterAtPosition(p:tPosC; var L : tListC);
	(*	Objetivo: Elimina de la lista el elemento que ocupa la posición indicada
		Entrada: Una lista y una posición
		Salida: El elemento en la posición indicada en esa lista
		Precondición La posición indicada es una posición válida en la lista
		Postcondición: Tanto la posición del elemento eliminado como aquellas de los elementos de la lista a continuación pueden cambiar de valor*)
	function getItemC(p:tPosC; L: tListC):tItemC;
	(*	Objetivo: Devuelve el contenido del elemento de la lista que ocupa la posición indicada
		Entrada: Una posición y una lista
		Salida: El elemento en esa posición de la lista
		Precondición: La posición indicada es una posición válida en la lista*)
	function findItemC(d:tCenterName; L:tListC):tPosC;
	(*	Objetivo: Encuentra el primer centro que coincida con el centro buscado y devuelve su posición.
		Entradas: Un centro y una lista
		Salidas: Una variable de posición
		Precondicion: La lista es no vacía
		Poscondicion: Si el centro no se encuentra en la lista la función devolverá NULLC*)
  procedure updateListC(newPartyList : tList; pos : tPosC; var centerList : tListC);
  (*  Objetivo: actualiza la lista de partidos de la posición indicada perteneciente a la lista de centros.
   Entradas: La lista de partidos nueva, la posición de la lista a actualizar, la lista de centros en la que se actualiza.
   Salidas: La lista de centros modificada
   Precondicion: La posición debe ser válida en la lista de centros
   *)
  procedure updateValidVotesC(newValidVotes : tNumVotes; pos : tPosC; var centerList : tListC);
  (*  Objetivo: actualiza los votos totales de la posición indicada perteneciente a la lista de centros.
   Entradas: El valor de votos nuevo, la posición de la lista a actualizar, la lista de centros en la que se actualiza.
   Salidas: La lista de centros modificada
   Precondicion: La posición debe ser válida en la lista de centros
   *)
	
implementation

	procedure createEmptyCenterList(var L:tListC);
		begin
			L.lst:= NULLC
		end;
		
	function isEmptyCenterList (L: tListC): boolean;
		begin
			isEmptyCenterList := (L.lst = NULLC);
		end;

	function firstC (L:tListC): tPosC;
		begin
			firstC:= 1;
		end;
		
	function lastC (L:tListC): tPosC;
		begin
			lastC:= L.lst;
		end;
		
	function nextC (p: tPosC; L: tListC): tPosC;
		begin
			if p=L.lst then
				nextC:=NULLC
		  else
				nextC:= p+1;
		end;

	function previousC (p: tPosC; L: tListC): tPosC;
		begin
			previousC:= p-1;
		end;
		
  function posInsert(d : tItemC; L : tListC): tPosC;
  var
    p : tPosC;
    begin
      p := firstC(L);
       while d.centername >= L.data[p].centername do
         p := nextC(p,L);
      posInsert := p;
    end;
		
		function insertItemC (d: tItemC, var L:tListC): boolean;

		begin
			if L.lst:= MAXC then
				insertItemC := false;
			else
			begin
				if (isEmptyCenterList(L)) or_then (d >= L.data[L.lst]) then
					L.data[L.lst +1] := d;
				else
					begin
						p:= L.lst;
						while (p>0) and (d <= L.data[p]) do
						begin
							L.data[p+1] := L.data[p];
							p:= previousC(p,L);
						end;
						L.data[p+1]:=d;
					end;
				L.lst := L.lst+1;
				insertItemC:= true;
			end;
		end;

		procedure deleteCenterAtPosition(p: tPosC; var L:tListC);
			var i: tPosC;
			begin
				L.lst := L.lst -1;
				for i:= p to L.lst do (*Se mueven todos los elementos siguientes a p una posición hacia atrás*)
					L.data[i] := L.data[i+1]; 
			end;
			
		function getItemC (p: tPosC; L: tListC): tItemC;
			begin
				getItemC:= L.data[p];
			end;

		function findItemC (d: tCenterName; L: tListC): tPosC;
			var i: tPosC;
			begin
				if isEmptyCenterList(L) then (*Se controla si la lista está vacía*)
					findItemC:= NULLC
				else
					begin
						i:=1;
          	while (i < L.lst) and (L.data[i].centername < d) do (*Se recorre la lista buscando el elemento y se sale del bucle cuando se lega al final o se pasa del elemento a buscar*)
				  		i:= i+1;
						if d = L.data[i].centername then
							findItemC:=i (*Si se encuentra, se devuelve la posición*)
						else
							findItemC := NULLC; (*Si se llega al final de la lista sin encontrarlo, se devuelve NULLC*)
					end;
		end;

    procedure updateListC(newPartyList: tList; pos: tPosC; var centerList: tListC);
    begin
       centerList.data[pos].partylist := newPartyList;  (*Se sobreescribe la nueva lista de partidos en la posición de la antigua*)
    end;

    procedure updateValidVotesC(newValidVotes: tNumVotes; pos: tPosC; var centerList: tListC);
    begin
       centerList.data[pos].validvotes := newValidVotes; (*Se sobreescribe el valor nuevo en la posición del viejo*)
    end;
end.
