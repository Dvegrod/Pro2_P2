Unit RequestQueue;

{
	TITLE: PROGRAMMING II LABS
	SUBTITLE: Practical 2
	AUTHOR 1: Carlos Torres Paz LOGIN 1: carlos.torres@udc.es
	AUTHOR 2: Daniel Sergio Vega Rodriguez LOGIN 2: d.s.vega@udc.es
	GROUP: 5.4
	DATE: 03/05/2019
}

interface

const
	NULLQ = 0;
	QUEUESIZE = 25;
	
type
   tRequest = char;
   tItemQ = record(* La cola almacena: el caracter de comando, el numero de línea, parametro 1 y parametro 2*)
                request : tRequest;
                code : string;
                param1 : string;
                param2 : string;
            end;
   tPosQ = 1 .. QUEUESIZE;
   tQueue =  record
                items: array [1..QUEUESIZE] of tItemQ;
                frst,lst: tPosQ; (*frst is the position of the first Item in the Queue, and lst is the position of the last item*)
             end;

procedure createEmptyQueue(var Q: tQueue);
(*
 Objetivo: inicializa una variable cola.
 Entrada: una variable cola.
 Salida: la variable cola inicializada.
 *)
{Para las siguientes se comparte la Precondición: la cola debe estar inicializada}
function isEmptyQueue(Q: tQueue):boolean;
(*
 Objetivo: informa si una cola está vacía.
 Entrada: una cola.
 Salida: un booleano TRUE si y solo si está vacía.
 *)
function enqueue(d: tItemQ; var Q: tQueue): boolean;
(*
 Objetivo: inserta un elemento nuevo al final de la cola.
 Entradas: el elemento a insertar y una cola en la que se inserta.
 Salidas: la cola modificada y un booleano que es TRUE si la operación se logró completar
 *)
function front(Q: tQueue):tItemQ;
(*
 Objetivo: Da por salida el elemento que se encuentra al frente de la cola.
 Entradas: una cola.
 Salidas: el elemento que se encuentra al frente de la cola dada.
 Precondición: la cola no está vacía.
 *)
procedure dequeue(var Q: tQueue);
(*
 Objetivo: elimina el elemento que se encuentre al frente de la cola.
 Entradas: una cola.
 Salidas: la cola modificada (Sin el primer elemento);
 Precondición: la cola no está vacía.
 *)

implementation

function nextQ(k: tPosQ): tPosQ; forward;
function IsFullQueue(Q: tQueue):boolean; forward;

procedure createEmptyQueue(var Q: tQueue);
begin
	Q.frst:= 1;
	Q.lst:= QUEUESIZE;
end;

function isEmptyQueue(Q:tQueue):boolean;
begin
	isEmptyQueue:= nextQ(Q.lst) = Q.frst;
end;

function enqueue(d: tItemQ; var Q:tQueue): boolean;
begin
	if not IsFullQueue(Q) then begin
		Q.lst:= nextQ(Q.lst);     (* Se actualiza el final de la cola y se introduce el nuevo elemento el el espacio nuevo *)
		Q.items[Q.lst] := d;
		enqueue:= true;
	end
	else
		enqueue:= false;
end;

function front(Q: tQueue):tItemQ;
begin
	front:= Q.items[Q.frst];
end;

procedure dequeue(var Q:tQueue);
begin
	Q.frst:=nextQ(Q.frst);
end;

function nextQ(k: tPosQ): tPosQ;
(*Objetivo: Retorna la posición siguiente a k en la Cola*)
begin
	nextQ:= (k mod QUEUESIZE)+1;
end;

function IsFullQueue(Q: tQueue): boolean;
begin
	IsFullQueue:= nextQ(nextQ(Q.lst)) = Q.frst;
end;

end.
