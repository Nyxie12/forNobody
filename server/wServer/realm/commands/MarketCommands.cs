using System;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using common;
using common.resources;
using TagLib;
using wServer.networking;
using wServer.realm.entities;
using wServer.realm.worlds;
using wServer.realm.worlds.logic;
using System.Collections.Generic;
using wServer.networking.packets;
using wServer.networking.packets.incoming;
using wServer.networking.packets.outgoing;
using File = TagLib.File;
using MarketResult = wServer.realm.entities.MarketResult;

namespace wServer.realm.commands
{
    class MarketCommand : Command
    {
        public MarketCommand() : base("market") { }

        private static Regex _regex = new Regex(@"^(\d+) (\d+)$", RegexOptions.IgnoreCase);

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (!(player.Owner is Marketplace))
            {
                player.SendError("Can only market items in Marketplace.");
                return false;
            }

            var match = _regex.Match(args);
            if (!match.Success || (match.Groups[1].Value.ToInt32()) > 16 || (match.Groups[1].Value.ToInt32()) < 1)
            {
                player.SendError("Usage: /market <slot> <amount>. Only slot numbers 1-16 are valid and amount must be a positive value.");
                return false;
            }
            
            int amount;
            if (!int.TryParse(match.Groups[2].Value, out amount))
            {
                player.SendError("Amount is too large. Try something below 2147483648...");
                return false;
            }

            var slot = match.Groups[1].Value.ToInt32() + 3;

            var result = player.AddToMarket(slot, amount);
            if (result != MarketResult.Success)
            {
                player.SendError(result.GetDescription());
                return false;
            }

            player.SendInfo("Success! Your item has been placed on the market.");
            return true;
        }
    }

    class MarketAllCommand : Command
    {
        public MarketAllCommand() : base("marketall", alias: "mall") { }

        private static Regex _regex = new Regex(@"^([A-Za-z0-9 ]+) (\d+)$", RegexOptions.IgnoreCase);

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (!(player.Owner is Marketplace))
            {
                player.SendError("Can only market items in Marketplace.");
                return false;
            }

            var match = _regex.Match(args);
            var gameData = player.Manager.Resources.GameData;
            ushort objType;
            int price;
            var sold = 0;
            bool err = false;

            if (!match.Success)
            {
                player.SendError("Usage: /marketall <item name> <price>.");
                return false;
            }

            string itemName = match.Groups[1].Value;

            // allow both DisplayId and Id for query
            if (!gameData.DisplayIdToObjectType.TryGetValue(itemName, out objType))
            {
                if (!gameData.IdToObjectType.TryGetValue(itemName, out objType))
                {
                    player.SendError("Unknown item type!");
                    return false;
                }
            }

            if (!gameData.Items.ContainsKey(objType))
            {
                player.SendError("Unknown item type!");
                return false;
            }

            if (gameData.Items[objType].Soulbound)
            {
                player.SendError("Can't market soulbound items!");
                return false;
            }

            if (!int.TryParse(match.Groups[2].Value, out price))
            {
                player.SendError("Price is too large. Try something below 2147483648...");
                return false;
            }

            for (int i = 4; i < player.Inventory.Length; i++)
            {
                if (player.Inventory[i]?.ObjectType != null && player.Inventory[i]?.ObjectType == objType)
                {
                    var result = player.AddToMarket(i, price);
                    if (result != MarketResult.Success)
                    {
                        player.SendError(result.GetDescription());
                        err = true;
                    } else
                    {
                        sold++;
                    }

                }
            }


            if (err)
            {
                if (sold > 0)
                {
                    player.SendErrorFormat("Errors occurred, only {0} item{1} sold.", sold, sold > 1 ? "s" : "");
                }
                else
                {
                    player.SendError("Errors occurred, couldn't market items.");
                }
                
            }
            else if (sold > 0)
            {
                player.SendInfoFormat("Success! Your {0} item{1} ha{2} been placed on the market.", sold, sold > 1 ? "s" : "", sold > 1 ? "ve" : "s");
            } 
            else
            {
                player.SendErrorFormat("No {0} found in your inventory.", gameData.Items[objType].DisplayName);
            }


            return true;
        }
    }

    class MyMarketCommand : Command
    {
        public MyMarketCommand() : base("myMarket") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var shopItems = player.GetMarketItems();
            if (shopItems.Length <= 0)
            {
                player.SendInfo("You have no items currently listed on the market.");
                return true;
            }

            player.SendInfo($"Your items ({shopItems.Length}): (format: [id] Name, fame)");
            foreach (var shopItem in shopItems)
            {
                var item = player.Manager.Resources.GameData.Items[shopItem.ItemId];
                player.SendInfo($"[{shopItem.Id}] {item.DisplayName}, {shopItem.Price}");
            }
            return true;
        }
    }

    class OopsCommand : Command
    {
        public OopsCommand() : base("oops") { }
        
        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.RemoveItemFromMarketAsync(player.Client.Account.LastMarketId)
                .ContinueWith(t =>
                {
                    if (t.Result != MarketResult.Success)
                    {
                        player.SendError(t.Result.GetDescription());
                        return;
                    }

                    player.SendInfo("Removal succeeded. The item has been placed in your gift chest.");
                    player.Client.SendPacket(new GlobalNotification
                    {
                        Text = "giftChestOccupied"
                    });
                })
                .ContinueWith(e =>
                    Log.Error(e.Exception.InnerException.ToString()),
                    TaskContinuationOptions.OnlyOnFaulted);

            return true;
        }
    }

    class RMarketCommand : Command
    {
        public RMarketCommand() : base("rmarket") { }
        
        protected override bool Process(Player player, RealmTime time, string args)
        {
            uint id;
            if (string.IsNullOrEmpty(args) ||
                !uint.TryParse(args, out id))
            {
                player.SendError("Usage: /rmarket <id>. Ids for your listed items can be found with the /mymarket command.");
                return false;
            }

            player.RemoveItemFromMarketAsync(id)
                .ContinueWith(t =>
                {
                    if (t.Result != MarketResult.Success)
                    {
                        player.SendError(t.Result.GetDescription());
                        return;
                    }

                    player.SendInfo("Removal succeeded. The item has been placed in your gift chest.");
                    player.Client.SendPacket(new GlobalNotification
                    {
                        Text = "giftChestOccupied"
                    });
                })
                .ContinueWith(e =>
                    Log.Error(e.Exception.InnerException.ToString()),
                    TaskContinuationOptions.OnlyOnFaulted);
            
            return true;
        }
    }

    class MarketplaceCommand : Command
    {
        public MarketplaceCommand() : base("marketplace") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Client.Reconnect(new Reconnect()
            {
                Host = "",
                Port = 2050,
                GameId = World.MarketPlace,
                Name = "Marketplace"
            });
            return true;
        }
    }

    class RemoveAccountOverrideCommand : Command
    {
        public RemoveAccountOverrideCommand() : base("removeOverride", 0, listCommand: false) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var acc = player.Client.Account;
            if (acc.AccountIdOverrider == 0)
            {
                player.SendError("Account isn't overridden.");
                return false;
            }

            var overriderAcc = player.Manager.Database.GetAccount(acc.AccountIdOverrider);
            if (overriderAcc == null)
            {
                player.SendError("Account not found!");
                return false;
            }

            overriderAcc.AccountIdOverride = 0;
            overriderAcc.FlushAsync();
            player.SendInfo("Account override removed.");
            return true;
        }
    }

    class CurrentSongCommand : Command
    {
        public CurrentSongCommand() : base("currentsong", alias: "song") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var properName = player.Owner.Music;
            var file = File.Create(Environment.CurrentDirectory + $"/resources/web/music/{properName}.mp3");
            var artist = file.Tag.FirstPerformer ?? "Unknown";
            var title = file.Tag.Title ?? properName;
            var album = file.Tag.Album != null ? $" from {file.Tag.Album}" : "";
            var filename = $" ({properName}.mp3)";
            
            player.SendInfo($"Current Song: {title} by {artist}{album}{filename}.");
            return true;
        }
    }

    class GuildKickCommand : Command
    {
        public GuildKickCommand() : base("gkick") { }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            if (player.Owner is Test)
                return false;

            var manager = player.Client.Manager;

            // if resigning
            if (player.Name.Equals(name))
            {
                // chat needs to be done before removal so we can use
                // srcPlayer as a source for guild info
                manager.Chat.Guild(player, player.Name + " has left the guild.", true);

                if (!manager.Database.RemoveFromGuild(player.Client.Account))
                {
                    player.SendError("Guild not found.");
                    return false;
                }

                player.Guild = "";
                player.GuildRank = 0;

                return true;
            }

            // get target account id
            var targetAccId = manager.Database.ResolveId(name);
            if (targetAccId == 0)
            {
                player.SendError("Player not found");
                return false;
            }

            // find target player (if connected)
            var targetClient = (from client in manager.Clients.Keys
                                where client.Account != null
                                where client.Account.AccountId == targetAccId
                                select client)
                                .FirstOrDefault();

            // try to remove connected member
            if (targetClient != null)
            {
                if (player.Client.Account.GuildRank >= 20 &&
                    player.Client.Account.GuildId == targetClient.Account.GuildId &&
                    player.Client.Account.GuildRank > targetClient.Account.GuildRank)
                {
                    var targetPlayer = targetClient.Player;

                    if (!manager.Database.RemoveFromGuild(targetClient.Account))
                    {
                        player.SendError("Guild not found.");
                        return false;
                    }

                    targetPlayer.Guild = "";
                    targetPlayer.GuildRank = 0;

                    manager.Chat.Guild(player,
                        targetPlayer.Name + " has been kicked from the guild by " + player.Name, true);
                    targetPlayer.SendInfo("You have been kicked from the guild.");
                    return true;
                }

                player.SendError("Can't remove member. Insufficient privileges.");
                return false;
            }

            // try to remove member via database
            var targetAccount = manager.Database.GetAccount(targetAccId);

            if (player.Client.Account.GuildRank >= 20 &&
                player.Client.Account.GuildId == targetAccount.GuildId &&
                player.Client.Account.GuildRank > targetAccount.GuildRank)
            {
                if (!manager.Database.RemoveFromGuild(targetAccount))
                {
                    player.SendError("Guild not found.");
                    return false;
                }

                manager.Chat.Guild(player,
                    targetAccount.Name + " has been kicked from the guild by " + player.Name, true);
                return true;
            }

            player.SendError("Can't remove member. Insufficient privileges.");
            return false;
        }
    }

    class GuildInviteCommand : Command
    {
        public GuildInviteCommand() : base("invite", alias: "ginvite") { }

        protected override bool Process(Player player, RealmTime time, string playerName)
        {
            if (player.Owner is Test)
                return false;

            if (player.Client.Account.GuildRank < 20)
            {
                player.SendError("Insufficient privileges.");
                return false;
            }

            var targetAccId = player.Client.Manager.Database.ResolveId(playerName);
            if (targetAccId == 0)
            {
                player.SendError("Player not found");
                return false;
            }

            var targetClient = (from client in player.Client.Manager.Clients.Keys
                                where client.Account != null
                                where client.Account.AccountId == targetAccId
                                select client)
                    .FirstOrDefault();

            if (targetClient != null)
            {
                if (targetClient.Player == null ||
                    targetClient.Account == null ||
                    !targetClient.Account.Name.Equals(playerName))
                {
                    player.SendError("Could not find the player to invite.");
                    return false;
                }

                if (!targetClient.Account.NameChosen)
                {
                    player.SendError("Player needs to choose a name first.");
                    return false;
                }

                if (targetClient.Account.GuildId > 0)
                {
                    player.SendError("Player is already in a guild.");
                    return false;
                }

                targetClient.Player.GuildInvite = player.Client.Account.GuildId;

                targetClient.SendPacket(new InvitedToGuild()
                {
                    Name = player.Name,
                    GuildName = player.Guild
                });
                return true;
            }

            player.SendError("Could not find the player to invite.");
            return false;
        }
    }

    class GuildWhoCommand : Command
    {
        public GuildWhoCommand() : base("gwho", alias: "mates") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player.Client.Account.GuildId == 0)
            {
                player.SendError("You are not in a guild!");
                return false;
            }
            
            var pServer = player.Manager.Config.serverInfo.name;
            var pGuild = player.Client.Account.GuildId;
            var servers = player.Manager.InterServer.GetServerList();
            var result =
                (from server in servers
                 from plr in server.playerList
                 where plr.GuildId == pGuild
                 group plr by server);
            
            
            player.SendInfo("Guild members online:");

            foreach (var group in result)
            {
               
                var server = (pServer == group.Key.name) ? $"[{group.Key.name}]" : group.Key.name;
                var players = group.ToArray();
                var sb = new StringBuilder($"{server}: ");
                for (var i = 0; i < players.Length; i++)
                {
                    if (i != 0)
                        sb.Append(", ");

                    sb.Append(players[i].Name);
                }
                player.SendInfo(sb.ToString());
            }
            return true;
        }
    }

    class SpectateCommand : Command
    {
        public SpectateCommand() : base("spectate") { }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                player.SendError("Usage: /spectate <player name>");
                return false;
            }

            var owner = player.Owner;
            if (!player.Client.Account.Admin && owner != null &&
                (owner is Arena || owner is ArenaSolo || owner is DeathArena))
            {
                player.SendInfo("Can't spectate in Arenas. (Temporary solution till we get spectate working across maps.)");
                return false;
            }

            var target = player.Owner.Players.Values
                .SingleOrDefault(p => p.Name.Equals(name, StringComparison.InvariantCultureIgnoreCase) && p.CanBeSeenBy(player));

            if (target == null)
            {
                player.SendError("Player not found. Note: Target player must be on the same map.");
                return false;
            }

            if (!player.Client.Account.Admin && 
                player.Owner.EnemiesCollision.HitTest(player.X, player.Y, 8).OfType<Enemy>().Any())
            {
                player.SendError("Enemies cannot be nearby when initiating spectator mode.");
                return false;
            }

            if (player.SpectateTarget != null)
            {
                player.SpectateTarget.FocusLost -= player.ResetFocus;
                player.SpectateTarget.Controller = null;
            }

            if (player != target)
            {
                player.ApplyConditionEffect(ConditionEffectIndex.Paused);
                target.FocusLost += player.ResetFocus;
                player.SpectateTarget = target;
            }
            else
            {
                player.SpectateTarget = null;
                player.Owner.Timers.Add(new WorldTimer(3000, (w, t) =>
                    {
                        if (player.SpectateTarget == null)
                            player.ApplyConditionEffect(ConditionEffectIndex.Paused, 0);
                    }));
            }

            player.Client.SendPacket(new SetFocus()
            {
                ObjectId = target.Id
            });

            player.SendInfo($"Now spectating {target.Name}. Use the /self command to exit.");
            return true;
        }
    }

    class SelfCommand : Command
    {
        public SelfCommand() : base("self") { }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            if (player.SpectateTarget != null)
            {
                player.SpectateTarget.FocusLost -= player.ResetFocus;
                player.SpectateTarget.Controller = null;
            }

            player.SpectateTarget = null;
            player.Sight.UpdateCount++;
            player.Owner.Timers.Add(new WorldTimer(3000, (w, t) =>
            {
                if (player.SpectateTarget == null)
                    player.ApplyConditionEffect(ConditionEffectIndex.Paused, 0);
            }));
            player.Client.SendPacket(new SetFocus()
            {
                ObjectId = player.Id
            });
            return true;
        }
    }

    class BazaarCommand : Command
    {
        public BazaarCommand() : base("bazaar") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Client.Reconnect(new Reconnect()
            {
                Host = "",
                Port = 2050,
                GameId = World.ClothBazaar,
                Name = "Cloth Bazaar"
            });
            return true;
        }
    }

    class ServersCommand : Command
    {
        public ServersCommand() : base("servers", alias: "svrs") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var playerSvr = player.Manager.Config.serverInfo.name;
            var servers = player.Manager.InterServer
                .GetServerList()
                .Where(s => s.type == ServerType.World)
                .ToArray();

            var sb = new StringBuilder($"Servers online ({servers.Length}):\n");
            foreach (var server in servers)
            {
                var currentSvr = server.name.Equals(playerSvr);
                if (currentSvr)
                {
                    sb.Append("[");
                }
                sb.Append(server.name);
                if (currentSvr)
                {
                    sb.Append("]");
                }
                sb.Append($" ({server.players}/{server.maxPlayers}");
                if (server.queueLength > 0)
                {
                    sb.Append($" + {server.queueLength} queued");
                }
                sb.Append(")");
                if (server.adminOnly)
                {
                    sb.Append(" Admin only");
                }
                sb.Append("\n");
            }
            
            player.SendInfo(sb.ToString());
            return true;
        }
    }
}
