-module(checkout).
-export([start/0,reset/1,scan/2,total/1,checkout/1]).

start() ->
	spawn(?MODULE, checkout, [[]]).

scan(Pid, Item) ->
	Pid ! {self(), {scan, Item}},
	receive
		{Pid, Msg} -> Msg
	end.

total(Pid) ->
	Pid ! {self(), total},
	receive
		{Pid, Msg} -> Msg
	end.

reset(Pid) ->
	Pid ! {self(), reset},
	receive
		{Pid, Msg} -> Msg
	end.

checkout(Items) ->
	PriceList = dict:from_list([{a,50}, {b,30}, {c,20},{d,15}]),
	Discounts = [{a,3,130},{b,2,45}],
	receive
		{From, {scan, NewItem}} ->
			From ! {self(), ok},
			checkout(lists:append(NewItem, Items));
		{From, total} ->
			From ! {self(), total_item_price(Items,PriceList) - total_discount_value(Items, PriceList, Discounts)},
			checkout(Items);
		{From, reset} ->
			From ! {self(), ok},
			checkout([]);
		terminate ->
			ok
	end.

total_item_price(Items, PriceList) ->
	lists:foldl(fun(Item, Acc) -> Acc + dict:fetch(Item, PriceList) end, 0, Items).

total_discount_value(Items, PriceList, Discounts) ->
	lists:foldl(fun(Discount, Acc) -> Acc + this_discount_value(Discount, Items, PriceList) end, 0, Discounts).

this_discount_value(Discount, Items, PriceList) ->
	{DiscountItem,DiscountThreshold,DiscountPrice} = Discount,
	discounts_to_apply(DiscountItem, Items, DiscountThreshold) * value_of_discount(DiscountItem, PriceList, DiscountPrice, DiscountThreshold).

discounts_to_apply(Item, Items, DiscountThreshold) ->
	trunc(item_count(Item, Items) / DiscountThreshold).

value_of_discount(DiscountItem, PriceList, DiscountPrice, DiscountThreshold) ->
	(dict:fetch(DiscountItem, PriceList) * DiscountThreshold) - DiscountPrice.

item_count(DiscountItem, Items) ->
	lists:foldl(fun(Item, Count) -> Count + increment_if_match(Item, DiscountItem) end, 0, Items).

increment_if_match(Item, Item) ->
	1;
increment_if_match(_, _) ->
	0.