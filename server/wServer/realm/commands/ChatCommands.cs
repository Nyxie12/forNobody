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
    class TellCommand : Command
    {
        public TellCommand() : base("tell") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (!player.NameChosen)
            {
                player.SendError("Choose a name!");
                return false;
            }

            if (player.Muted)
            {
                player.SendError("Muted. You can not tell at this time.");
                return false;
            }

            int index = args.IndexOf(' ');
            if (index == -1)
            {
                player.SendError("Usage: /tell <player name> <text>");
                return false;
            }

            string playername = args.Substring(0, index);
            string msg = args.Substring(index + 1);

            if (player.Name.ToLower() == playername.ToLower())
            {
                player.SendInfo("Quit telling yourself!");
                return false;
            }

            if (!player.Manager.Chat.Tell(player, playername, msg))
            {
                player.SendError(string.Format("{0} not found.", playername));
                return false;
            }
            return true;
        }
    }

    class GCommand : Command
    {
        public GCommand() : base("g") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (!player.NameChosen)
            {
                player.SendError("Choose a name!");
                return false;
            }

            if (player.Muted)
            {
                player.SendError("Muted. You can not guild chat at this time.");
                return false;
            }

            if (String.IsNullOrEmpty(player.Guild))
            {
                player.SendError("You need to be in a guild to guild chat.");
                return false;
            }

            return player.Manager.Chat.Guild(player, args);
        }
    }

    class IgnoreCommand : Command
    {
        public IgnoreCommand() : base("ignore") { }

        protected override bool Process(Player player, RealmTime time, string playerName)
        {
            if (player.Owner is Test)
                return false;

            if (String.IsNullOrEmpty(playerName))
            {
                player.SendError("Usage: /ignore <player name>");
                return false;
            }

            if (player.Name.ToLower() == playerName.ToLower())
            {
                player.SendInfo("Can't ignore yourself!");
                return false;
            }

            var target = player.Manager.Database.ResolveId(playerName);
            var targetAccount = player.Manager.Database.GetAccount(target);
            var srcAccount = player.Client.Account;

            if (target == 0 || targetAccount == null || targetAccount.Hidden && player.Admin == 0)
            {
                player.SendError("Player not found.");
                return false;
            }

            player.Manager.Database.IgnoreAccount(srcAccount, targetAccount, true);

            player.Client.SendPacket(new AccountList()
            {
                AccountListId = 1, // ignore list
                AccountIds = srcAccount.IgnoreList
                    .Select(i => i.ToString())
                    .ToArray()
            });

            player.SendInfo(playerName + " has been added to your ignore list.");
            return true;
        }
    }

    class UnignoreCommand : Command
    {
        public UnignoreCommand() : base("unignore") { }

        protected override bool Process(Player player, RealmTime time, string playerName)
        {
            if (player.Owner is Test)
                return false;

            if (String.IsNullOrEmpty(playerName))
            {
                player.SendError("Usage: /unignore <player name>");
                return false;
            }

            if (player.Name.ToLower() == playerName.ToLower())
            {
                player.SendInfo("You are no longer ignoring yourself. Good job.");
                return false;
            }

            var target = player.Manager.Database.ResolveId(playerName);
            var targetAccount = player.Manager.Database.GetAccount(target);
            var srcAccount = player.Client.Account;

            if (target == 0 || targetAccount == null || targetAccount.Hidden && player.Admin == 0)
            {
                player.SendError("Player not found.");
                return false;
            }

            player.Manager.Database.IgnoreAccount(srcAccount, targetAccount, false);

            player.Client.SendPacket(new AccountList()
            {
                AccountListId = 1,
                AccountIds = srcAccount.IgnoreList
                    .Select(i => i.ToString())
                    .ToArray()
            });

            player.SendInfo(playerName + " no longer ignored.");
            return true;
        }
    }

    class LockCommand : Command
    {
        public LockCommand() : base("lock") { }

        protected override bool Process(Player player, RealmTime time, string playerName)
        {
            if (player.Owner is Test)
                return false;

            if (String.IsNullOrEmpty(playerName))
            {
                player.SendError("Usage: /lock <player name>");
                return false;
            }

            if (player.Name.ToLower() == playerName.ToLower())
            {
                player.SendInfo("Can't lock yourself!");
                return false;
            }

            var target = player.Manager.Database.ResolveId(playerName);
            var targetAccount = player.Manager.Database.GetAccount(target);
            var srcAccount = player.Client.Account;

            if (target == 0 || targetAccount == null || targetAccount.Hidden && player.Admin == 0)
            {
                player.SendError("Player not found.");
                return false;
            }

            player.Manager.Database.LockAccount(srcAccount, targetAccount, true);

            player.Client.SendPacket(new AccountList()
            {
                AccountListId = 0,
                AccountIds = player.Client.Account.LockList
                    .Select(i => i.ToString())
                    .ToArray(),
                LockAction = 1
            });

            player.SendInfo(playerName + " has been locked.");
            return true;
        }
    }

    class UnlockCommand : Command
    {
        public UnlockCommand() : base("unlock") { }

        protected override bool Process(Player player, RealmTime time, string playerName)
        {
            if (player.Owner is Test)
                return false;

            if (String.IsNullOrEmpty(playerName))
            {
                player.SendError("Usage: /unlock <player name>");
                return false;
            }

            if (player.Name.ToLower() == playerName.ToLower())
            {
                player.SendInfo("You are no longer locking yourself. Nice!");
                return false;
            }

            var target = player.Manager.Database.ResolveId(playerName);
            var targetAccount = player.Manager.Database.GetAccount(target);
            var srcAccount = player.Client.Account;

            if (target == 0 || targetAccount == null || targetAccount.Hidden && player.Admin == 0)
            {
                player.SendError("Player not found.");
                return false;
            }

            player.Manager.Database.LockAccount(srcAccount, targetAccount, false);

            player.Client.SendPacket(new AccountList()
            {
                AccountListId = 0,
                AccountIds = player.Client.Account.LockList
                    .Select(i => i.ToString())
                    .ToArray(),
                LockAction = 0
            });

            player.SendInfo(playerName + " no longer locked.");
            return true;
        }
    }

    class TradeCommand : Command
    {
        public TradeCommand() : base("trade") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (String.IsNullOrWhiteSpace(args))
            {
                player.SendError("Usage: /trade <player name>");
                return false;
            }

            player.RequestTrade(args);
            return true;
        }
    }

    class JoinGuildCommand : Command
    {
        public JoinGuildCommand() : base("join") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Client.ProcessPacket(new JoinGuild()
            {
                GuildName = args
            });
            return true;
        }
    }

    class TeleportCommand : Command
    {
        public TeleportCommand() : base("tp", alias: "teleport") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            foreach (var i in player.Owner.Players.Values)
            {
                if (!i.Name.EqualsIgnoreCase(args))
                    continue;

                if (!i.CanBeSeenBy(player))
                    break;

                player.Teleport(time, i.Id);
                return true;
            }

            player.SendError($"Unable to find player: {args}");
            return false;
        }
    }

    class DungeonAccept : Command
    {
        public DungeonAccept() : base("daccept") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            int id;
            try
            {
                id = int.Parse(args);
            }
            catch (Exception)
            {
                player.SendError("ID must be a number.");
                return false;
            }
            var world = player.Manager.GetWorld(id);
            if (world != null)
            {
                if (world.PlayerDungeon && world.Invites.Contains(player.Name.ToLower()))
                {
                    if (world.GetAge() > 90000)
                    {
                        player.SendError("The invite has expired.");
                        return false;
                    }
                    else
                    {
                        world.Invites.Remove(player.Name.ToLower());
                        player.Client.Reconnect(new Reconnect()
                        {
                            Host = "",
                            Port = 2050,
                            GameId = world.Id,
                            Name = world.SBName != null ? world.SBName : world.Name,
                        });
                        return true;
                    }
                }
                else if (world.PlayerDungeon && world.Invited.Contains(player.Name.ToLower()))
                {
                    player.SendError("You have already entered " + world.GetDisplayName() + ".");
                    return false;
                }
                else
                {
                    player.SendError("You were not invited to join " + world.GetDisplayName() + ".");
                    return false;
                }
            }
            else
            {
                player.SendError("The world was not found.");
                return false;
            }
        }
    }

    class DungeonInvite : Command
    {
        public DungeonInvite() : base("dinvite") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {

            if (!(player.Owner.PlayerDungeon && player.Owner.Opener.Equals(player.Name)))
            {
                player.SendError("This is not your dungeon!");
                return false;
            }
            else if (player.Owner.GetAge() > 90000)
            {
                player.SendError("It's too late to invite players!");
                return false;
            }

            HashSet<string> invited = new HashSet<string>();
            HashSet<string> missed = new HashSet<string>();
            HashSet<string> unable = new HashSet<string>();

            if (args.Contains("-g"))
            {
                foreach (var i in player.Manager.Clients.Keys
                    .Where(x => x.Player != null)
                    .Where(x => !x.Account.IgnoreList.Contains(player.AccountId))
                    .Where(x => x.Account.GuildId > 0)
                    .Where(x => x.Account.GuildId == player.Client.Account.GuildId)
                    .Select(x => x.Player))
                {
                    if (i.Name.EqualsIgnoreCase(player.Name)) continue;

                    // already in the dungeon
                    if (i.Owner.Id == player.Owner.Id)
                    {
                        unable.Add(i.Name);
                        player.Owner.Invited.Add(i.Name.ToLower());
                        continue;
                    }

                    if (player.Owner.Invited.Contains(i.Name.ToLower()))
                    {
                        unable.Add(i.Name);
                    }
                    else if (player.Manager.Chat.Invite(player, i.Name, player.Owner.GetDisplayName(), player.Owner.Id))
                    {
                        player.Owner.Invited.Add(i.Name.ToLower());
                        player.Owner.Invites.Add(i.Name.ToLower());
                        invited.Add(i.Name);
                    }
                    else
                    {
                        missed.Add(i.Name);
                    }
                }

                if (invited.Count > 0)
                {
                    player.SendInfo("Invited: " + string.Join(", ", invited));
                }
                if (unable.Count > 0)
                {
                    player.SendInfo("Already invited: " + string.Join(", ", unable));
                }
                if (missed.Count > 0)
                {
                    player.SendInfo("Not found: " + string.Join(", ", missed));
                }
                return true;
            }

            var players = args.Split(' ').Where(n => !n.Equals("")).ToArray();

            if (players.Length > 0)
            {
                foreach (string p in players)
                {
                    if (p.EqualsIgnoreCase(player.Name)) continue;

                    if (player.Owner.Invited.Contains(p.ToLower()))
                    {
                        unable.Add(p);
                    }
                    else if (player.Manager.Chat.Invite(player, p, player.Owner.GetDisplayName(), player.Owner.Id))
                    {
                        player.Owner.Invited.Add(p.ToLower());
                        player.Owner.Invites.Add(p.ToLower());
                        invited.Add(p);
                    }
                    else
                    {
                        missed.Add(p);
                    }
                }
                if (invited.Count > 0)
                {
                    player.SendInfo("Invited: " + string.Join(", ", invited));
                }
                if (unable.Count > 0)
                {
                    player.SendInfo("Already invited: " + string.Join(", ", unable));
                }
                if (missed.Count > 0)
                {
                    player.SendInfo("Not found: " + string.Join(", ", missed));
                }
                return true;
            }
            else
            {
                player.SendError("Specify some players to invite!");
                return false;
            }
        }
    }
}
