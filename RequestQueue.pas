Unit RequestQueue;

interface

const
	NULLQ = 0;
	QUEUESIZE = 25;
	
type
    tRequest = char;
	tItemQ = record
                request = tRequest;
                code = string;
                param1 = string;
                param2 = string;
            end;
    tPosQ = 1 .. QUEUESIZE;
	tQueue =  record
			items: array [1..QUEUESIZE] of tDato;
			frst,lst: tPosQ; (*frst is the position of the first Item in the Queue, and lst is the position of the last item*)
			end;

procedure CreateEmptyQueue(var Q: tQueue);
function IsEmptyQueue(Q: tQueue):boolean;
function enqueue(d: tItem, var Q: tQueue): boolean;
function front(Q: tQueue):tItem;
procedure dequeue(var Q: tQueue);
	
implementation

procedure CreateEmptyQueue(var Q: tQueue);
begin
	Q.frst:= 1;
	Q.lst:= QUEUESIZE;
end;

function IsEmptyQueue(Q:tQueue):boolean;
begin
	IsEmptyQueue:= nextQ(Q.lst) = Q.frst;
end;

function enqueue(d: tItem, var Q:tQueue): boolean;
begin
	if not IsFullQueue(Q) then begin
		Q.lst:= nextQ(Q.lst);
		Q.items[Q.lst] := d;
		enqueue:= true;
	end
	else
		enqueue:= false;
end;

function front(Q: tQueue):tItem;
begin
	front:= Q.items[Q.frst];
end;

procedure dequeue(var Q:tQueue);
begin
	Q.frst=nextQ(Q.frst);
end;

function nextQ(k: tPosQ): tPosQ;
(*Objetivo: Returns the next position to k in the Queue*)
begin
	nextQ:= (k mod QUEUESIZE)+1;
end;

function IsFullQueue(Q: tQueue): boolean;
begin
	IsFullQueue:= nextQ(nextQ(Q.lst)) = Q.frst;
end;

