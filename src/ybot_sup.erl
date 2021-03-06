%%%----------------------------------------------------------------------
%%% File    : ybot_sup.erl
%%% Author  : 0xAX <anotherworldofworld@gmail.com>
%%% Purpose : Ybot root supervisor
%%%----------------------------------------------------------------------
-module(ybot_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    % Start crypto        
    ok = application:start(crypto),
    % Start public key
    ok = application:start(public_key),
    % Start ssl
    ok = application:start(ssl),

    % Get plugins directory
    {ok, PluginsDirectory} = application:get_env(ybot, plugins_path),
    % Get transports
    {ok, Transports} = application:get_env(ybot, transports),

    % Root supervisor childrens
    Childrens = [

        % run irc root supervisor
        {irc_lib_sup,
            {irc_lib_sup, start_link, []},
            permanent, brutal_kill, supervisor, []
        },

        % run xmpp root supervisor
        {xmpp_sup,
            {xmpp_sup, start_link, []},
            permanent, brutal_kill, supervisor, []
        },

        % run campfire root supervisor
        {campfire_sup,
            {campfire_sup, start_link, []},
            permanent, brutal_kill, supervisor, []
        },

        % start manager with transports list
        {ybot_manager,
            {ybot_manager, start_link, [PluginsDirectory, Transports]},
             permanent, brutal_kill, worker, []
        }
    ],

    % init
    {ok, { {one_for_one, 5, 10}, Childrens} }.
