-module(checkout_tests).
-include_lib("eunit/include/eunit.hrl").

checkout_test_() ->
	{"all tests",
	{setup,
	fun setup/0,
	fun teardown/1,
	fun checkout_tests/1}}.

setup() ->
	Checkout = checkout:start(),
	Checkout.

teardown(Checkout) ->
	Checkout ! terminate.

checkout_tests(Checkout) ->
	[
		?_assertEqual(0, price_for_items([], Checkout)),
		?_assertEqual(50, price_for_items([a], Checkout)),
		?_assertEqual(30, price_for_items([b], Checkout)),
		?_assertEqual(20, price_for_items([c], Checkout)),
		?_assertEqual(15, price_for_items([d], Checkout)),
		?_assertEqual(130, price_for_items([a,a,a], Checkout)),
		?_assertEqual(100, price_for_items([a,a], Checkout)),
		?_assertEqual(180, price_for_items([a,a,a,a], Checkout)),
		?_assertEqual(230, price_for_items([a,a,a,a,a], Checkout)),
		?_assertEqual(260, price_for_items([a,a,a,a,a,a], Checkout)),
		?_assertEqual(45, price_for_items([b,b], Checkout)),
		?_assertEqual(210, price_for_items([a,b,a,b,a,c,d], Checkout))
	].

price_for_items(Items, Checkout) ->
	checkout:reset(Checkout),
	checkout:scan(Checkout, Items),
	checkout:total(Checkout).	
