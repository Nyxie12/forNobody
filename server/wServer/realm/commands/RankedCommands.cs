using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using common;
using common.resources;
using log4net;
using Newtonsoft.Json;
using wServer.networking;
using wServer.networking.packets.outgoing;
using wServer.realm.setpieces;
using wServer.realm.entities;
using wServer.realm.worlds;
using wServer.realm.worlds.logic;

namespace wServer.realm.commands
{
    class SpawnCommand : Command
    {
        static readonly ILog log = LogManager.GetLogger(typeof(SpawnCommand));

        private struct JsonSpawn
        {
            public string notif;
            public SpawnProperties[] spawns;
        }

        private struct SpawnProperties
        {
            public string name;
            public int? hp;
            public int? size;
            public int? count;
            public int[] x;
            public int[] y;
            public bool? target;
        }

        private const int Delay = 3;

        public SpawnCommand() : base("spawn", permLevel: 90) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            args = args.Trim();
            return args.StartsWith("{") ?
                SpawnJson(player, args) :
                SpawnBasic(player, args);
        }

        private bool SpawnJson(Player player, string json)
        {
            var gameData = player.Manager.Resources.GameData;

            JsonSpawn props;
            try
            {
                props = JsonConvert.DeserializeObject<JsonSpawn>(json);
            }
            catch (Exception)
            {
                player.SendError("JSON not formatted correctly!");
                return false;
            }

            if (props.spawns != null)
                foreach (var spawn in props.spawns)
                {
                    if (spawn.name == null)
                    {
                        player.SendError("No mob specified. Every entry needs a name property.");
                        return false;
                    }

                    var objType = GetSpawnObjectType(gameData, spawn.name);
                    if (objType == null)
                    {
                        player.SendError("Unknown entity!");
                        return false;
                    }

                    var desc = gameData.ObjectDescs[objType.Value];

                    if (player.Client.Account.Rank < 100 &&
                        player.Owner is DeathArena &&
                        desc.ObjectId.Contains("Fountain"))
                    {
                        player.SendError("Insufficient rank.");
                        return false;
                    }

                    var hp = desc.MaxHP;
                    if (spawn.hp > hp && spawn.hp < int.MaxValue)
                        hp = spawn.hp.Value;

                    var size = desc.MinSize;
                    if (spawn.size >= 25 && spawn.size <= 500)
                        size = spawn.size.Value;

                    var count = 1;
                    if (spawn.count > count && spawn.count <= 500)
                        count = spawn.count.Value;

                    int[] x = null;
                    int[] y = null;

                    if (spawn.x != null)
                        x = new int[spawn.x.Length];

                    if (spawn.y != null)
                        y = new int[spawn.y.Length];

                    if (x != null)
                    {
                        for (int i = 0; i < x.Length && i < count; i++)
                        {
                            if (spawn.x[i] > 0 && spawn.x[i] <= player.Owner.Map.Width)
                            {
                                x[i] = spawn.x[i];
                            }

                        }

                    }

                    if (y != null)
                    {
                        for (int i = 0; i < y.Length && i < count; i++)
                        {
                            if (spawn.y[i] > 0 && spawn.y[i] <= player.Owner.Map.Height)
                            {
                                y[i] = spawn.y[i];
                            }

                        }

                    }

                    bool target = false;
                    if (spawn.target != null)
                        target = spawn.target.Value;

                    QueueSpawnEvent(player, count, objType.Value, hp, size, x, y, target);
                }

            if (props.notif != null)
            {
                NotifySpawn(player, props.notif);
            }


            return true;
        }

        private bool SpawnBasic(Player player, string args)
        {
            var gameData = player.Manager.Resources.GameData;

            // split argument
            var index = args.IndexOf(' ');
            int num;
            var name = args;
            if (args.IndexOf(' ') > 0 && int.TryParse(args.Substring(0, args.IndexOf(' ')), out num)) //multi
                name = args.Substring(index + 1);
            else
                num = 1;

            var objType = GetSpawnObjectType(gameData, name);
            if (objType == null)
            {
                player.SendError("Unknown entity!");
                return false;
            }

            if (num <= 0)
            {
                player.SendInfo($"Really? {num} {name}? I'll get right on that...");
                return false;
            }

            var id = player.Manager.Resources.GameData.ObjectTypeToId[objType.Value];
            if (player.Client.Account.Rank < 100 &&
                player.Owner is DeathArena &&
                id.Contains("Fountain"))
            {
                player.SendError("Insufficient rank.");
                return false;
            }

            NotifySpawn(player, id, num);
            QueueSpawnEvent(player, num, objType.Value);
            return true;
        }

        private ushort? GetSpawnObjectType(XmlData gameData, string name)
        {
            ushort objType;
            if (!gameData.IdToObjectType.TryGetValue(name, out objType) ||
                !gameData.ObjectDescs.ContainsKey(objType))
            {
                // no match found, try to get partial match
                var mobs = gameData.IdToObjectType
                    .Where(m => m.Key.ContainsIgnoreCase(name) && gameData.ObjectDescs.ContainsKey(m.Value))
                    .Select(m => gameData.ObjectDescs[m.Value]);

                if (!mobs.Any())
                    return null;

                var maxHp = mobs.Max(e => e.MaxHP);
                objType = mobs.First(e => e.MaxHP == maxHp).ObjectType;
            }

            return objType;
        }

        private void NotifySpawn(Player player, string mob, int? num = null)
        {
            var w = player.Owner;

            var notif = mob;
            if (num != null)
                notif = "Spawning " + ((num > 1) ? num + " " : "") + mob + "...";

            w.BroadcastPacket(new Notification
            {
                Color = new ARGB(0xffff0000),
                ObjectId = (player.IsControlling) ? player.SpectateTarget.Id : player.Id,
                Message = notif
            }, null, PacketPriority.Low);

            if (player.IsControlling)
                w.BroadcastPacket(new Text
                {
                    Name = $"#{player.SpectateTarget.ObjectDesc.DisplayId}",
                    NumStars = -1,
                    BubbleTime = 0,
                    Txt = notif
                }, null, PacketPriority.Low);
            else
                w.BroadcastPacket(new Text
                {
                    Name = $"#{player.Name}",
                    NumStars = player.Stars,
                    Admin = player.Admin,
                    BubbleTime = 0,
                    Txt = notif
                }, null, PacketPriority.Low);
        }

        private void QueueSpawnEvent(
            Player player,
            int num,
            ushort mobObjectType, int? hp = null, int? size = null,
            int[] x = null, int[] y = null,
            bool? target = false)
        {
            var pX = player.X;
            var pY = player.Y;

            player.Owner.Timers.Add(new WorldTimer(Delay * 1000, (world, t) => // spawn mob in delay seconds
            {
                for (var i = 0; i < num && i < 500; i++)
                {
                    Entity entity;
                    try
                    {
                        entity = Entity.Resolve(world.Manager, mobObjectType);
                    }
                    catch (Exception e)
                    {
                        log.ErrorFormat(e.ToString());
                        return;
                    }

                    var enemy = entity as Enemy;
                    if (enemy != null)
                    {
                        if (hp != null)
                        {
                            enemy.HP = hp.Value;
                            enemy.MaximumHP = enemy.HP;
                        }

                        if (size != null)
                            enemy.SetDefaultSize(size.Value);

                        if (target == true)
                            enemy.AttackTarget = player;

                        enemy.ApplyConditionEffect(new ConditionEffect()
                        {
                            Effect = ConditionEffectIndex.Invisible,
                            DurationMS = -1
                        });
                    }

                    var sX = (x != null && i < x.Length) ? x[i] : pX;
                    var sY = (y != null && i < y.Length) ? y[i] : pY;

                    entity.Move(sX, sY);

                    if (!world.Deleted)
                        world.EnterWorld(entity);
                }
            }));
        }
    }

    class ClearGravesCommand : Command
    {
        public ClearGravesCommand() : base("cleargraves", permLevel: 70) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var removed = 0;
            foreach (var entity in player.Owner.StaticObjects.Values)
            {
                if (entity is Container || entity.ObjectDesc == null)
                    continue;

                if (entity.ObjectDesc.ObjectId.StartsWith("Gravestone") && entity.Dist(player) < 15)
                {
                    player.Owner.LeaveWorld(entity);
                    removed++;
                }
            }

            player.SendInfo($"{removed} gravestones removed!");
            return true;
        }
    }

    class ToggleEffCommand : Command
    {
        public ToggleEffCommand() : base("eff", alias:"addeff", permLevel: 90) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            ConditionEffectIndex effect;
            if (!Enum.TryParse(args, true, out effect))
            {
                player.SendError("Invalid effect!");
                return false;
            }

            var target = player.IsControlling ? player.SpectateTarget : player;
            if ((target.ConditionEffects & (ConditionEffects)((ulong)1 << (int)effect)) != 0)
            {
                player.SendInfo("Effect has been removed!");
                target.ApplyConditionEffect(new ConditionEffect()
                {
                    Effect = effect,
                    DurationMS = 0
                });
            }
            else
            {
                player.SendInfo("Effect has been applied!");
                target.ApplyConditionEffect(new ConditionEffect()
                {
                    Effect = effect,
                    DurationMS = -1
                });
            }
            return true;
        }
    }

    class GimmeCommand : Command
    {
        public GimmeCommand() : base("give", permLevel: 80) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var gameData = player.Manager.Resources.GameData;

            ushort objType;

            // allow both DisplayId and Id for query
            if (!gameData.DisplayIdToObjectType.TryGetValue(args, out objType))
            {
                if (!gameData.IdToObjectType.TryGetValue(args, out objType))
                {
                    player.SendError("Unknown item type!");
                    return false;
                }
            }

            if (!gameData.Items.ContainsKey(objType))
            {
                player.SendError("Not an item!");
                return false;
            }

            var item = gameData.Items[objType];

            if (player.Client.Account.Rank < 100 &&
                (
            #region Banned Items
                 item.DisplayName.Equals("Boshy Gun") || 
                 item.DisplayName.Equals("Dark Helm") ||
                 item.DisplayName.Equals("Unholy Spell") ||
                 item.DisplayName.Equals("Golden Apple") ||
                 item.DisplayName.Equals("Boshy Shotgun") ||
                 item.DisplayName.Equals("50 Fame") ||
                 item.DisplayName.Equals("100 Fame") ||
                 item.DisplayName.Equals("500 Fame") ||
                 item.DisplayName.Equals("1000 Fame") ||
                 item.DisplayName.Equals("5000 Fame") ||
                 item.DisplayName.Equals("Oryx's Arena Key")
            #endregion
                 ))
            {
                player.SendError("Insufficient rank.");
                return false;
            }

            var availableSlot = player.Inventory.GetAvailableInventorySlot(item);
            if (availableSlot != -1)
            {
                player.SendInfo($"[\"{item}\"] has been given!");
                player.Inventory[availableSlot] = item;
                return true;
            }

            player.SendError("Not enough space in inventory!");
            return false;
        }
    }

    class TpPosCommand : Command
    {
        public TpPosCommand() : base("tpPos", permLevel: 90) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            string[] coordinates = args.Split(' ');
            if (coordinates.Length != 2)
            {
                player.SendError("Invalid coordinates!");
                return false;
            }

            int x, y;
            if (!int.TryParse(coordinates[0], out x) ||
                !int.TryParse(coordinates[1], out y))
            {
                player.SendError("Invalid coordinates!");
                return false;
            }

            player.SetNewbiePeriod();
            player.TeleportPosition(time, x + 0.5f, y + 0.5f, true);
            return true;
        }
    }

    class SetpieceCommand : Command
    {
        public SetpieceCommand() : base("setpiece", permLevel: 100) { }

        protected override bool Process(Player player, RealmTime time, string setPiece)
        {
            if (String.IsNullOrWhiteSpace(setPiece))
            {
                var type = typeof(ISetPiece);
                var types = AppDomain.CurrentDomain.GetAssemblies()
                    .SelectMany(s => s.GetTypes())
                    .Where(p => type.IsAssignableFrom(p) && !p.IsAbstract);
                var msg = types.Aggregate(
                    "Valid SetPieces: ", (c, p) => c + (p.Name) + ", ");
                player.SendInfo(msg.Substring(0, msg.Length - 2) + ".");
                return false;
            }

            if (!player.Owner.Name.Equals("Nexus"))
            {
                try
                {
                    ISetPiece piece = (ISetPiece)Activator.CreateInstance(Type.GetType(
                    "wServer.realm.setpieces." + setPiece, true, true));
                    piece.RenderSetPiece(player.Owner, new IntPoint((int)player.X + 1, (int)player.Y + 1));
                    return true;
                }
                catch (Exception)
                {
                    player.SendError("Invalid SetPiece.");
                    return false;
                }
            }
            else
            {
                player.SendInfo("/setpiece not allowed in Nexus. (Yes, I'm talking to you Q.)");
                return false;
            }
        }
    }

    class KillAllCommand : Command
    {
        public KillAllCommand() : base("killall", permLevel: 90) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var iterations = 0;
            var lastKilled = -1;
            var killed = 0;
            while (killed != lastKilled)
            {
                lastKilled = killed;
                foreach (var i in player.Owner.Enemies.Values.Where(e =>
                    e.ObjectDesc != null && e.ObjectDesc.ObjectId != null
                    && e.ObjectDesc.Enemy && e.ObjectDesc.ObjectId != "Tradabad Nexus Crier"
                    && e.ObjectDesc.ObjectId.ContainsIgnoreCase(args)))
                {
                    i.Spawned = true;
                    i.Death(time);
                    killed++;
                }
                if (++iterations >= 5)
                    break;
            }

            player.SendInfo($"{killed} enemy killed!");
            return true;
        }
    }

    class KickCommand : Command
    {
        public KickCommand() : base("kick", permLevel: 80) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            foreach (var i in player.Manager.Clients.Keys)
            {
                if (i.Account.Name.EqualsIgnoreCase(args))
                {
                    if (i.Account.Hidden)
                        break;

                    i.Disconnect();
                    player.SendInfo("Player disconnected!");
                    return true;
                }
            }
            player.SendError($"Player '{args}' could not be found!");
            return false;
        }
    }

    class OryxSayCommand : Command
    {
        public OryxSayCommand() : base("oryxSay", permLevel: 80, alias: "osay") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Manager.Chat.Oryx(player.Owner, args);
            return true;
        }
    }

    class AnnounceCommand : Command
    {
        public AnnounceCommand() : base("announce", permLevel: 80) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Manager.Chat.Announce(args);
            return true;
        }
    }

    class SummonCommand : Command
    {
        public SummonCommand() : base("summon", permLevel: 90) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {

            foreach (var i in player.Owner.Players)
            {
                if (i.Value.Name.EqualsIgnoreCase(args))
                {
                    if (i.Value.HasConditionEffect(ConditionEffects.Hidden))
                        break;

                    i.Value.Teleport(time, player.Id, true);
                    i.Value.SendInfo($"You've been summoned by {player.Name}.");
                    player.SendInfo("Player summoned!");
                    return true;
                }
            }
            player.SendError($"Player '{args}' could not be found!");
            return false;
        }
    }

    class SummonAllCommand : Command
    {
        public SummonAllCommand() : base("summonall", permLevel: 90) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            foreach (var i in player.Owner.Players)
            {
                i.Value.Teleport(time, player.Id, true);
                i.Value.SendInfo($"You've been summoned by {player.Name}.");
            }

            player.SendInfo("All players summoned!");
            return true;
        }
    }

    class KillPlayerCommand : Command
    {
        public KillPlayerCommand() : base("kill", permLevel: 100) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            foreach (var i in player.Manager.Clients.Keys)
            {
                if (i.Account.Name.EqualsIgnoreCase(args))
                {
                    i.Player.HP = 0;
                    i.Player.Death(player.Name);
                    player.SendInfo("Player killed!");
                    return true;
                }
            }
            player.SendError($"Player '{args}' could not be found!");
            return false;
        }
    }

    class SizeCommand : Command
    {
        public SizeCommand() : base("size", permLevel: 10) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (string.IsNullOrEmpty(args))
            {
                player.SendError("Usage: /size <positive integer>. Using 0 will restore the default size for the sprite.");
                return false;
            }

            var size = Utils.FromString(args);
            var min = player.Rank < 80 ? 75 : 0;
            var max = player.Rank < 80 ? 125 : 500;
            if (size < min && size != 0 || size > max)
            {
                player.SendError($"Invalid size. Size needs to be within the range: {min}-{max}. Use 0 to reset size to default.");
                return false;
            }
            
            var acc = player.Client.Account;
            acc.Size = size;
            acc.FlushAsync();
            
            var target = player.IsControlling ? player.SpectateTarget : player;
            if (size == 0)
                target.RestoreDefaultSize();
            else
                target.Size = size;
            
            return true;
        }
    }

    class MaxCommand : Command
    {
        public MaxCommand() : base("max", permLevel: 80) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var pd = player.Manager.Resources.GameData.Classes[player.ObjectType];

            player.Stats.Base[0] = pd.Stats[0].MaxValue;
            player.Stats.Base[1] = pd.Stats[1].MaxValue;
            player.Stats.Base[2] = pd.Stats[2].MaxValue;
            player.Stats.Base[3] = pd.Stats[3].MaxValue;
            player.Stats.Base[4] = pd.Stats[4].MaxValue;
            player.Stats.Base[5] = pd.Stats[5].MaxValue;
            player.Stats.Base[6] = pd.Stats[6].MaxValue;
            player.Stats.Base[7] = pd.Stats[7].MaxValue;

            player.SendInfo("Your character stats have been maxed.");
            return true;
        }
    }

    class TpQuestCommand : Command
    {
        public TpQuestCommand() : base("tq", permLevel: 90) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player.Quest == null)
            {
                player.SendError("Player does not have a quest!");
                return false;
            }
            
            player.SetNewbiePeriod();
            player.TeleportPosition(time, player.Quest.RealX, player.Quest.RealY, true);
            player.SendInfo("Teleported to Quest Location: (" + player.Quest.X + ", " + player.Quest.Y + ")");
            return true;
        }
    }

    class RankCommand : Command
    {
        public RankCommand() : base("rank", permLevel: 110) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var index = args.IndexOf(' ');
            if (string.IsNullOrEmpty(args) || index == -1)
            {
                player.SendInfo("Usage: /rank <player name> <rank>");
                return false;
            }

            var name = args.Substring(0, index);
            var rank = int.Parse(args.Substring(index + 1));

            if (Database.GuestNames.Contains(name, StringComparer.InvariantCultureIgnoreCase))
            {
                player.SendError("Cannot rank unnamed accounts.");
                return false;
            }

            var id = player.Manager.Database.ResolveId(name);
            if (id == player.AccountId)
            {
                player.SendError("Cannot rank self.");
                return false;
            }

            var acc = player.Manager.Database.GetAccount(id);
            if (id == 0 || acc == null)
            {
                player.SendError("Account not found!");
                return false;
            }

            // kick player from server to set rank
            foreach (var i in player.Manager.Clients.Keys)
                if (i.Account.Name.EqualsIgnoreCase(name))
                    i.Disconnect();

            if (acc.Admin && rank < 80)
            {
                // reset account
                player.Manager.Database.WipeAccount(
                    acc, player.Manager.Resources.GameData, player.Name);
                acc.Reload();
            }

            acc.Admin = rank >= 80;
            acc.LegacyRank = rank;
            acc.Hidden = false;
            acc.FlushAsync();

            player.SendInfo($"{acc.Name} given legacy rank {acc.LegacyRank}{((acc.Admin) ? " and now has admin status" : "")}.");
            return true;
        }
    }

    class MuteCommand : Command
    {
        private static readonly Regex CmdParams = new Regex(@"^(\w+)( \d+)?$", RegexOptions.IgnoreCase);

        private readonly RealmManager _manager;

        public MuteCommand(RealmManager manager) : base("mute", permLevel: 80)
        {
            _manager = manager;
            _manager.DbEvents.Expired += HandleUnMute;
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var match = CmdParams.Match(args);
            if (!match.Success)
            {
                player?.SendError("Usage: /mute <player name> <time out in minutes>\\n" +
                                 "Time parameter is optional. If left out player will be muted until unmuted.");
                return false;
            }

            // gather arguments
            var name = match.Groups[1].Value;
            var id = _manager.Database.ResolveId(name);
            var acc = _manager.Database.GetAccount(id);
            int timeout;
            if (string.IsNullOrEmpty(match.Groups[2].Value))
            {
                timeout = -1;
            }
            else
            {
                int.TryParse(match.Groups[2].Value, out timeout);
            }
            
            // run through checks
            if (id == 0 || acc == null)
            {
                player?.SendError("Account not found!");
                return false;
            }
            if (acc.IP == null)
            {
                player?.SendError("Account has no associated IP address. Player must login at least once before being muted.");
                return false;
            }
            if (acc.IP.Equals(player?.Client.Account.IP))
            {
                player?.SendError("Mute failed. That action would cause yourself to be muted (IPs are the same).");
                return false;
            }
            if (acc.Admin)
            {
                player?.SendError("Cannot mute other admins.");
                return false;
            }

            // mute player if currently connected
            foreach (var client in _manager.Clients.Keys
                        .Where(c => c.Player != null && c.IP.Equals(acc.IP) && !c.Player.Client.Account.Admin))
            {
                client.Player.Muted = true;
                client.Player.ApplyConditionEffect(ConditionEffectIndex.Muted);
            }

            if (player != null)
            {
                if (timeout > 0)
                    _manager.Chat.SendInfo(id, "You have been muted by " + player.Name + " for " + timeout + " minutes.");
                else
                    _manager.Chat.SendInfo(id, "You have been muted by " + player.Name + ".");
            }

            // mute ip address
            if (timeout < 0)
            {
                _manager.Database.Mute(acc.IP);
                player?.SendInfo(name + " successfully muted indefinitely.");
            }
            else
            {
                _manager.Database.Mute(acc.IP, TimeSpan.FromMinutes(timeout));
                player?.SendInfo(name + " successfully muted for " + timeout + " minutes.");
            }

            return true;
        }

        private void HandleUnMute(object entity, DbEventArgs expired)
        {
            var key = expired.Message;

            if (!key.StartsWith("mutes:"))
                return;

            foreach (var client in _manager.Clients.Keys.Where(c => 
                c.Player != null && c.IP.Equals(key.Substring(6)) && !c.Player.Client.Account.Admin))
            {
                client.Player.Muted = false;
                client.Player.ApplyConditionEffect(ConditionEffectIndex.Muted, 0);
                client.Player.SendInfo("You are no longer muted. Please do not spam. Thank you.");
            }
        }
    }

    class UnMuteCommand : Command
    {
        public UnMuteCommand() : base("unmute", permLevel: 80) { }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                player.SendError("Usage: /unmute <player name>");
                return false;
            }

            // gather needed info
            var id = player.Manager.Database.ResolveId(name);
            var acc = player.Manager.Database.GetAccount(id);

            // run checks
            if (id == 0 || acc == null)
            {
                player.SendError("Account not found!");
                return false;
            }
            if (acc.IP == null)
            {
                player.SendError("Account has no associated IP address. Player must login at least once before being unmuted.");
                return false;
            }

            // unmute ip address
            player.Manager.Database.IsMuted(acc.IP).ContinueWith(t =>
            {
                if (!t.IsCompleted)
                {
                    player.SendInfo("Db access error while trying to unmute.");
                    return;
                }

                if (t.Result)
                {
                    player.Manager.Database.Mute(acc.IP, TimeSpan.FromSeconds(1));
                    player.SendInfo(name + " successfully unmuted.");
                }
                else
                {
                    player.SendInfo(name + " wasn't muted...");
                }
            });
            
            // expire event will handle unmuting of connected players
            return true;
        }
    }

    class BanAccountCommand : Command
    {
        public BanAccountCommand() : base("ban", permLevel: 80) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            BanInfo bInfo;
            if (args.StartsWith("{"))
            {
                bInfo = Utils.FromJson<BanInfo>(args);
            }
            else
            {
                bInfo = new BanInfo();

                // validate command
                var rgx = new Regex(@"^(\w+) (.+)$");
                var match = rgx.Match(args);
                if (!match.Success)
                {
                    player.SendError("Usage: /ban <account id or name> <reason>");
                    return false;
                }

                // get info from args
                bInfo.Name = match.Groups[1].Value;
                if (!int.TryParse(bInfo.Name, out bInfo.accountId))
                {
                    bInfo.accountId = player.Manager.Database.ResolveId(bInfo.Name);
                }
                bInfo.banReasons = match.Groups[2].Value;
                bInfo.banLiftTime = -1;
            }

            // run checks
            if (Database.GuestNames.Any(n => n.ToLower().Equals(bInfo.Name?.ToLower())))
            {
                player.SendError("If you specify a player name to ban, the name needs to be unique.");
                return false;
            }
            if (bInfo.accountId == 0)
            {
                player.SendError("Account not found...");
                return false;
            }
            if (string.IsNullOrWhiteSpace(bInfo.banReasons))
            {
                player.SendError("A reason must be provided.");
                return false;
            }
            var acc = player.Manager.Database.GetAccount(bInfo.accountId);
            if (player.AccountId != acc.AccountId && player.Rank <= acc.Rank)
            {
                player.SendError("Cannot ban players of equal or higher rank than yourself.");
                return false;
            }

            // ban player + disconnect if currently connected
            player.Manager.Database.Ban(bInfo.accountId, bInfo.banReasons, bInfo.banLiftTime);
            var target = player.Manager.Clients.Keys
                .SingleOrDefault(c => c.Account != null && c.Account.AccountId == bInfo.accountId);
            target?.Disconnect();

            player.SendInfo(!string.IsNullOrEmpty(bInfo.Name) ? 
                $"{bInfo.Name} successfully banned." : 
                "Ban successful.");
            return true;
        }

        private class BanInfo
        {
            public int accountId;
            public string Name;
            public string banReasons;
            public int banLiftTime;
        }
    }
    
    class BanIPCommand : Command
    {
        public BanIPCommand() : base("banip", permLevel: 80, alias: "ipban") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var manager = player.Manager;
            var db = manager.Database;

            // validate command
            var rgx = new Regex(@"^(\w+) (.+)$");
            var match = rgx.Match(args);
            if (!match.Success)
            {
                player.SendError("Usage: /banip <account id or name> <reason>");
                return false;
            }

            // get info from args
            int id;
            var idstr = match.Groups[1].Value;
            if (!int.TryParse(idstr, out id))
            {
                id = db.ResolveId(idstr);
            }
            var reason = match.Groups[2].Value;

            // run checks
            if (Database.GuestNames.Any(n => n.ToLower().Equals(idstr.ToLower())))
            {
                player.SendError("If you specify a player name to ban, the name needs to be unique.");
                return false;
            }
            if (id == 0)
            {
                player.SendError("Account not found...");
                return false;
            }
            if (string.IsNullOrWhiteSpace(reason))
            {
                player.SendError("A reason must be provided.");
                return false;
            }
            var acc = db.GetAccount(id);
            if (string.IsNullOrEmpty(acc.IP))
            {
                player.SendError("Failed to ip ban player. IP not logged...");
                return false;
            }
            if (player.AccountId != acc.AccountId && acc.IP.Equals(player.Client.Account.IP))
            {
                player.SendError("IP ban failed. That action would cause yourself to be banned (IPs are the same).");
                return false;
            }
            if (player.AccountId != acc.AccountId && player.Rank <= acc.Rank)
            {
                player.SendError("Cannot ban players of equal or higher rank than yourself.");
                return false;
            }

            // ban
            db.Ban(acc.AccountId, reason);
            db.BanIp(acc.IP, reason);
            
            // disconnect currently connected
            var targets = manager.Clients.Keys.Where(c => c.IP.Equals(acc.IP));
            foreach (var t in targets)
                t.Disconnect();

            // send notification
            player.SendInfo($"Banned {acc.Name} (both account and ip).");
            return true;
        }
    }

    class UnBanAccountCommand : Command
    {
        public UnBanAccountCommand() : base("unban", permLevel: 80) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var db = player.Manager.Database;

            // validate command
            var rgx = new Regex(@"^(\w+)$");
            if (!rgx.IsMatch(args))
            {
                player.SendError("Usage: /unban <account id or name>");
                return false;
            }

            // get info from args
            int id;
            if (!int.TryParse(args, out id))
                id = db.ResolveId(args);

            // run checks
            if (id == 0)
            {
                player.SendError("Account doesn't exist...");
                return false;
            }

            var acc = db.GetAccount(id);

            // unban
            var banned = db.UnBan(id);
            var ipBanned = acc.IP != null && db.UnBanIp(acc.IP);

            // send notification
            if (!banned && !ipBanned)
            {
                player.SendInfo($"{acc.Name} wasn't banned...");
                return true;
            }
            if (banned && ipBanned)
            {
                player.SendInfo($"Success! {acc.Name}'s account and IP no longer banned.");
                return true;
            }
            if (banned)
            {
                player.SendInfo($"Success! {acc.Name}'s account no longer banned.");
                return true;
            }

            player.SendInfo($"Success! {acc.Name}'s IP no longer banned.");
            return true;
        }
    }

    class ClearInvCommand : Command
    {
        public ClearInvCommand() : base("clearinv", permLevel: 80) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            for (int i = 4; i < 12; i++)
                player.Inventory[i] = null;
            player.SendInfo("Inventory Cleared.");
            return true;
        }
    }

    class MusicCommand : Command
    {
        public MusicCommand() : base("music", permLevel: 70) { }

        protected override bool Process(Player player, RealmTime time, string music)
        {
            var resources = player.Manager.Resources;

            if (string.IsNullOrWhiteSpace(music))
            {
                var msg = resources.MusicNames.Aggregate(
                    "Music Choices: ", (c, p) => c + (p + ", "));
                player.SendInfo(msg.Substring(0, msg.Length - 2) + ".");
                return false;
            }

            var properName = resources.MusicNames
                .FirstOrDefault(s => s.Equals(music, StringComparison.InvariantCultureIgnoreCase));
            if (properName == null)
            {
                player.SendError($"Music \"{music}\" not found!");
                return false;
            }

            var owner = player.Owner;
            owner.Music = properName;

            foreach (var plr in owner.Players.Values)
                plr.SendInfo($"World music changed to {properName}.");

            var i = 0;
            foreach (var plr in owner.Players.Values)
            {
                owner.Timers.Add(new WorldTimer(100 * i, (w, t) =>
                {
                    if (plr == null)
                        return;

                    plr.Client.SendPacket(new SwitchMusic()
                    {
                        Music = properName
                    });
                }));
                i++;
            }
            return true;
        }
    }

    class CloseRealmCommand : Command
    {
        public CloseRealmCommand() : base("closerealm", permLevel: 80) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var gw = player.Manager.Worlds[World.Realm] as Realm;

            if (gw == null)
            {
                player.SendError("An undefined error occurred.");
                return false;
            }

            if (gw.IsClosing())
            {
                player.SendError("Realm already closing.");
                return false;
            }

            gw.CloseRealm();
            return true;
        }
    }

    class QuakeCommand : Command
    {
        public QuakeCommand() : base("quake", permLevel: 80) { }

        protected override bool Process(Player player, RealmTime time, string worldName)
        {
            var worldProtoData = player.Manager.Resources.Worlds.Data;

            if (String.IsNullOrWhiteSpace(worldName))
            {
                var msg = worldProtoData.Aggregate(
                    "Valid World Names: ", (c, p) => c + ((!p.Value.setpiece) ? (p.Key + ", ") : ""));
                player.SendInfo(msg.Substring(0, msg.Length - 2) + ".");
                return false;
            }

            var worldNameProper =
                player.Manager.Resources.Worlds.Data.FirstOrDefault(
                    p => p.Key.Equals(worldName, StringComparison.InvariantCultureIgnoreCase)).Key;

            ProtoWorld proto;
            if (worldNameProper == null || (proto = worldProtoData[worldNameProper]).setpiece)
            {
                player.SendError("Invalid world.");
                return false;
            }

            return true;
        }
    }

    class VisitCommand : Command
    {
        public VisitCommand() : base("visit", permLevel: 80) { }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                player.SendInfo("Usage: /visit <player name>");
                return true;
            }

            var target = player.Manager.Clients.Keys
                .SingleOrDefault(c => c.Account != null &&
                                      c.Account.Name.Equals(name, StringComparison.InvariantCultureIgnoreCase));

            if (target?.Player?.Owner == null ||
                !target.Player.CanBeSeenBy(player))
            {
                player.SendError("Player not found!");
                return false;
            }

            var owner = target.Player.Owner;
            player.Client.Reconnect(new Reconnect()
            {
                Host = "",
                GameId = owner.Id,
                Name = owner.SBName
            });
            return true;
        }
    }

    class HideCommand : Command
    {
        public HideCommand() : base("hide", permLevel: 80, alias: "h") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var acc = player.Client.Account;

            acc.Hidden = !acc.Hidden;
            acc.FlushAsync();

            if (acc.Hidden)
            {
                player.ApplyConditionEffect(ConditionEffectIndex.Hidden);
                player.ApplyConditionEffect(ConditionEffectIndex.Invincible);
                player.Manager.Clients[player.Client].Hidden = true;
            }
            else
            {
                player.ApplyConditionEffect(ConditionEffectIndex.Hidden, 0);
                player.ApplyConditionEffect(ConditionEffectIndex.Invincible, 0);
                player.Manager.Clients[player.Client].Hidden = false;
            }

            return true;
        }
    }

    class GlowCommand : Command
    {
        public GlowCommand() : base("glow", permLevel: 70) { }

        protected override bool Process(Player player, RealmTime time, string color)
        {
            if (String.IsNullOrWhiteSpace(color))
            {
                player.SendInfo("Usage: /glow <color>");
                return true;
            }

            player.Glow = Utils.FromString(color);

            var acc = player.Client.Account;
            acc.GlowColor = player.Glow;
            acc.FlushAsync();

            return true;
        }
    }

    class LinkCommand : Command
    {
        public LinkCommand() : base("link", permLevel: 90) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player?.Owner == null)
                return false;

            var world = player.Owner;
            if (world.Id < 0 || (player.Rank < 80 && !(world is Test)))
            {
                player.SendError("Forbidden.");
                return false;
            }

            if (!player.Manager.Monitor.AddPortal(world.Id))
            {
                player.SendError("Link already exists.");
                return false;
            }

            return true;
        }
    }

    class UnLinkCommand : Command
    {
        public UnLinkCommand() : base("unlink", permLevel: 90) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player?.Owner == null)
                return false;

            var world = player.Owner;
            if (world.Id < 0 || (player.Rank < 80 && !(world is Test)))
            {
                player.SendError("Forbidden.");
                return false;
            }

            if (!player.Manager.Monitor.RemovePortal(player.Owner.Id))
                player.SendError("Link not found.");
            else
                player.SendInfo("Link removed.");

            return true;
        }
    }

    class GiftCommand : Command
    {
        public GiftCommand() : base("gift", permLevel: 100) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player == null)
                return false;

            var manager = player.Manager;

            // verify argument
            var index = args.IndexOf(' ');
            if (string.IsNullOrWhiteSpace(args) || index == -1)
            {
                player.SendInfo("Usage: /gift <player name> <item name>");
                return false;
            }

            // get command args
            var playerName = args.Substring(0, index);
            var item = GetItem(player, args.Substring(index + 1));
            if (item == null)
            {
                return false;
            }

            // get player account
            if (Database.GuestNames.Contains(playerName, StringComparer.InvariantCultureIgnoreCase))
            {
                player.SendError("Cannot gift the unnamed...");
                return false;
            }
            var id = manager.Database.ResolveId(playerName);
            var acc = manager.Database.GetAccount(id);
            if (id == 0 || acc == null)
            {
                player.SendError("Account not found!");
                return false;
            }

            // add gift
            var result = player.Manager.Database.AddGift(acc, item.ObjectType);
            if (!result)
            {
                player.SendError("Gift not added. Something happened with the adding process.");
                return false;
            }

            // send out success notifications
            player.SendInfoFormat("You gifted {0} one {1}.", acc.Name, item.DisplayName);
            var gifted = player.Manager.Clients.Keys
                .SingleOrDefault(p => p.Account.AccountId == acc.AccountId);
            gifted?.Player?.SendInfoFormat(
                "You received a gift from {0}. Enjoy your {1}.",
                player.Name,
                item.DisplayName);
            return true;
        }

        private Item GetItem(Player player, string itemName)
        {
            var gameData = player.Manager.Resources.GameData;

            ushort objType;

            // allow both DisplayId and Id for query
            if (!gameData.DisplayIdToObjectType.TryGetValue(itemName, out objType))
            {
                if (!gameData.IdToObjectType.TryGetValue(itemName, out objType))
                    player.SendError("Unknown item type!");
                return null;
            }

            if (!gameData.Items.ContainsKey(objType))
            {
                player.SendError("Not an item!");
                return null;
            }


            return gameData.Items[objType];
        }
    }

    class Level20Command : Command
    {
        public Level20Command() : base("level", permLevel: 70) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player.Level < 20)
            {
                player.Experience = Player.GetLevelExp(20);
                player.Level = 20;
                player.CalculateFame();
                return true;
            }

            return false;
        }
    }

    class RenameCommand : Command
    {
        public RenameCommand() : base("rename", permLevel: 100) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var index = args.IndexOf(' ');
            if (string.IsNullOrWhiteSpace(args) || index == -1)
            {
                player.SendInfo("Usage: /rename <player name> <new player name>");
                return false;
            }

            var playerName = args.Substring(0, index);
            var newPlayerName = args.Substring(index + 1);

            var id = player.Manager.Database.ResolveId(playerName);
            if (id == 0)
            {
                player.SendError("Player account not found!");
                return false;
            }

            if (newPlayerName.Length < 3 || newPlayerName.Length > 15 || !newPlayerName.All(char.IsLetter) ||
                Database.GuestNames.Contains(newPlayerName, StringComparer.InvariantCultureIgnoreCase))
            {
                player.SendError("New name is invalid. Must be between 3-15 char long and contain only letters.");
                return false;
            }

            string lockToken = null;
            var key = Database.NAME_LOCK;
            var db = player.Manager.Database;

            try
            {
                while ((lockToken = db.AcquireLock(key)) == null) ;

                if (db.Conn.HashExists("names", newPlayerName.ToUpperInvariant()))
                {
                    player.SendError("Name already taken");
                    return false;
                }

                var acc = db.GetAccount(id);
                if (acc == null)
                {
                    player.SendError("Account doesn't exist.");
                    return false;
                }

                using (var l = db.Lock(acc))
                    if (db.LockOk(l))
                    {
                        while (!db.RenameIGN(acc, newPlayerName, lockToken)) ;
                        player.SendInfo("Rename successful.");
                    }
                    else
                        player.SendError("Account in use.");
            }
            finally
            {
                if (lockToken != null)
                    db.ReleaseLock(key, lockToken);
            }

            return true;
        }
    }

    class UnnameCommand : Command
    {
        public UnnameCommand() : base("unname", permLevel: 100) { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (string.IsNullOrWhiteSpace(args))
            {
                player.SendInfo("Usage: /unname <player name>");
                return false;
            }

            var playerName = args;

            var id = player.Manager.Database.ResolveId(playerName);
            if (id == 0)
            {
                player.SendError("Player account not found!");
                return false;
            }

            string lockToken = null;
            var key = Database.NAME_LOCK;
            var db = player.Manager.Database;

            try
            {
                while ((lockToken = db.AcquireLock(key)) == null) ;

                var acc = db.GetAccount(id);
                if (acc == null)
                {
                    player.SendError("Account doesn't exist.");
                    return false;
                }

                using (var l = db.Lock(acc))
                    if (db.LockOk(l))
                    {
                        while (!db.UnnameIGN(acc, lockToken)) ;
                        player.SendInfo("Account succesfully unnamed.");
                    }
                    else
                        player.SendError("Account in use.");
            }
            finally
            {
                if (lockToken != null)
                    db.ReleaseLock(key, lockToken);
            }

            return true;
        }
    }

    class WargCommand : Command
    {
        public WargCommand() : base("warg", permLevel: 90) { }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                player.SendError("Usage: /warg <mob name>");
                return false;
            }

            var target = player.GetNearestEntityByName(2900, name);
            if (target == null)
            {
                player.SendError("Mob not found.");
                return false;
            }

            if (target.Controller != null)
            {
                player.SendError("Only one person can control a mob at a time.");
                return false;
            }

            if (player.SpectateTarget != null)
            {
                player.SpectateTarget.FocusLost -= player.ResetFocus;
                player.SpectateTarget.Controller = null;
            }

            player.ApplyConditionEffect(ConditionEffectIndex.Hidden);
            player.ApplyConditionEffect(ConditionEffectIndex.Invincible);
            player.ApplyConditionEffect(ConditionEffectIndex.Stunned);
            target.FocusLost += player.ResetFocus;
            target.Controller = player;
            player.SpectateTarget = target;
            player.Sight.UpdateCount++;

            player.Owner.Timers.Add(new WorldTimer(500, (w, t) =>
            {
                player.Client.SendPacket(new SetFocus()
                {
                    ObjectId = target.Id
                });
            }));
            return true;
        }
    }
}
