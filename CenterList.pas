unit CenterList;

{
	TITLE: PROGRAMMING II LABS
	SUBTITLE: Practical 1
	AUTHOR 1: Carlos Torres Paz LOGIN 1: carlos.torres@udc.es
	AUTHOR 2: Daniel Sergio Vega Rodriguez LOGIN 2: d.s.vega@udc.es
	GROUP: 5.4
	DATE: 22/02/2019
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
                totalvoters : tNumVotes;
                validvotes  : tNumVotes;
                partylist   : tList;
             end;

		tListC = record
					data: array [1..MAXC] of tItemC;
					fin: tPosC;
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
	(*	Objetivo: Encuentra el primer partido que coincida con el partido buscado y devuelve su posición.
		Entradas: Un partido político y una lista
		Salidas: Una variable de posición
		Precondicion: La lista es no vacía
		Poscondicion: Si el partido no se encuentra en la lista la función devolverá NULL*)
	
implementation

	procedure createEmptyCenterList(var L:tListC);
		begin
			L.fin:= NULLC
		end;
		
	function isEmptyCenterList (L: tListC): boolean;
		begin
			isEmptyCenterList := (L.fin = NULLC);
		end;

	function firstC (L:tListC): tPosC;
		begin
			firstC:= 1;
		end;
		
	function lastC (L:tListC): tPosC;
		begin
			lastC:= L.fin;
		end;
		
	function previousC (p: tPosC; L: tListC): tPosC;
		begin
			previousC:= p-1;
		end;
		
	function nextC (p: tPosC; L: tListC): tPosC;
		begin
			if p=L.fin then
				nextC:=NULLC
		  else
				nextC:= p+1;
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
	

	function insertItemC(d: tItemC; var L:tListC):boolean;
    var
       p : tPosC;
    begin
			if L.fin = MAXC then (*Se controla si el array está lleno*)
				insertItemC:= FALSE
			else
				begin
           if (L.fin = 0) or (d.centername >= L.data[L.fin].centername) then
             L.data[L.fin + 1] := d
          else begin
             p := L.fin;
             while (p <> NULLC) and (d.centername <= L.data[p].centername) do
             begin
                L.data[p+1] := L.data[p];
                p := previousC(p,L);
             end;
             L.data[p+1] := d;
           end;
           insertItemC:=TRUE;
           L.fin := L.fin + 1;
        end;
		end;

		procedure deleteCenterAtPosition(p: tPosC; var L:tListC);
			var i: tPosC;
			begin
				L.fin := L.fin -1;
				for i:= p to L.fin do (*Se mueven todos los elementos siguientes a p una posición hacia atrás*)
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
					i:=1;
          while (i < L.fin) and (L.data[i].centername < d) do (*Se recorre la lista buscando el elemento y se sale del bucle cuando se lega al final o se encuentra*)
				  	i:= i+1;
					if d = L.data[i].centername then
						findItemC:=i (*Si se encuentra, se devuelve la posición*)
					else
						findItemC := NULLC; (*Si se llega al final de la lista sin encontrarlo, se devuelve NULLC*)
		end;
end.
