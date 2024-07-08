-module(persistent_regex_ffi).

-export([get/1]).

get(Term) ->
    try {ok, persistent_term:get(Term)}
    catch error:badarg -> {error, nil}
    end.