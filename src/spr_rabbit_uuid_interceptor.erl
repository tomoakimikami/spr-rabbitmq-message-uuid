%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.
%%
%% The Original Code is RabbitMQ Message Timestamp.
%%
%% The Initial Developer of the Original Code is GoPivotal, Inc.
%% Copyright (c) 2007-2016 Pivotal Software, Inc.  All rights reserved.
%%

-module(spr_rabbit_uuid_interceptor).

-include_lib("rabbit_common/include/rabbit.hrl").
-include_lib("rabbit_common/include/rabbit_framing.hrl").
-include_lib("uuid/include/uuid.hrl").

-behaviour(rabbit_channel_interceptor).

-export([description/0, intercept/3, applies_to/0, init/1]).

-rabbit_boot_step({?MODULE,
                   [{description, "uuid interceptor"},
                    {mfa, {rabbit_registry, register,
                           [channel_interceptor,
                            <<"uuid interceptor">>, ?MODULE]}},
                    {cleanup, {rabbit_registry, unregister,
                               [channel_interceptor,
                                <<"uuid interceptor">>]}},
                    {requires, rabbit_registry},
                    {enables, recovery}]}).

init(_Ch) ->
    undefined.

description() ->
    [{description,
      <<"Adds current timestamp to messages as they enter RabbitMQ">>}].

intercept(#'basic.publish'{} = Method, Content, _IState) ->
    DecodedContent = rabbit_binary_parser:ensure_content_decoded(Content),
    V4 = uuid:get_v4(),
    Uuid = list_to_binary(uuid:uuid_to_string(V4)),
    Content2 = set_content_uuid(DecodedContent, Uuid),
    {Method, Content2};

intercept(Method, Content, _VHost) ->
    {Method, Content}.

applies_to() ->
    ['basic.publish'].

%%----------------------------------------------------------------------------

                                                % Do not overwrite an existing timestamp
set_content_uuid(#content{properties = Props} = Content, _)
  when is_list(Props#'P_basic'.message_id) ->
    Content;

set_content_uuid(#content{properties = Props} = Content, Uuid)
  when Props#'P_basic'.message_id == undefined ->
    %% we need to reset properties_bin = none so the new properties
    %% get serialized when deliverying the message.
    Content#content{properties = Props#'P_basic'{message_id = Uuid},
                    properties_bin = none}.

