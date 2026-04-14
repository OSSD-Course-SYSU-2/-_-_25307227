
import { Bubble, Level, Item, Equipment, Player } from '../models/GameModels';
export interface EquipmentData {
  id: number;
  currentLevel: number;
}

export interface SaveData {
  totalScore: number;
  currentLevel: number;
  coins: number;
  highestScore: number;
  items: [number, number][];
  equipments: EquipmentData[];
}

/**
 * 游戏数据管理器
 */
export class GameDataManager {
  private static instance: GameDataManager;
  public player: Player;
  public levels: Level[] = [];
  public items: Item[] = [];
  public equipments: Equipment[] = [];

  private constructor() {
    this.player = new Player();
    this.initLevels();
    this.initItems();
    this.initEquipments();
  }

  static getInstance(): GameDataManager {
    if (!GameDataManager.instance) {
      GameDataManager.instance = new GameDataManager();
    }
    return GameDataManager.instance;
  }

  /**
   * 初始化关卡数据
   */
  private initLevels(): void {
    for (let i = 1; i <= 20; i++) {
      const targetScore = 100 + (i - 1) * 50;
      const bubbleCount = 20 + (i - 1) * 5;
      const timeLimit = Math.max(30, 60 - (i - 1) * 2);
      const reward = 50 + (i - 1) * 20;
      this.levels.push(new Level(i, targetScore, bubbleCount, timeLimit, reward));
    }
  }

  /**
   * 初始化道具数据
   */
  private initItems(): void {
    this.items = [
      new Item(1, '双倍积分卡', '使用后30秒内获得双倍积分', 100, 'double_score', 30),
      new Item(2, '时间延长', '增加15秒游戏时间', 80, 'time_extend', 15),
      new Item(3, '磁铁', '自动吸引附近泡泡', 150, 'magnet', 20),
      new Item(4, '炸弹', '消除屏幕上所有泡泡', 200, 'bomb', 0),
      new Item(5, '护盾', '保护一次失误', 120, 'shield', 0)
    ];
  }

  /**
   * 初始化装备数据
   */
  private initEquipments(): void {
    this.equipments = [
      new Equipment(1, '积分加成', '提升基础积分获取', 200, 0.15),
      new Equipment(2, '金币加成', '提升金币获取量', 180, 0.12),
      new Equipment(3, '泡泡大小', '增加泡泡显示大小', 150, 0.08),
      new Equipment(4, '时间延长', '增加关卡时间限制', 250, 0.1),
      new Equipment(5, '连击加成', '提升连击积分倍率', 300, 0.2)
    ];

    // 初始化玩家装备
    this.equipments.forEach(eq => {
      this.player.equipments.set(eq.id, eq);
    });
  }

  /**
   * 获取当前关卡
   */
  getCurrentLevel(): Level {
    const levelIndex = Math.min(this.player.currentLevel - 1, this.levels.length - 1);
    return this.levels[levelIndex];
  }

  /**
   * 购买道具
   */
  buyItem(itemId: number): boolean {
    const item = this.items.find(i => i.id === itemId);
    if (item && this.player.spendCoins(item.price)) {
      const currentCount = this.player.items.get(itemId) || 0;
      this.player.items.set(itemId, currentCount + 1);
      return true;
    }
    return false;
  }

  /**
   * 使用道具
   */
  useItem(itemId: number): boolean {
    const currentCount = this.player.items.get(itemId) || 0;
    if (currentCount > 0) {
      this.player.items.set(itemId, currentCount - 1);
      return true;
    }
    return false;
  }

  /**
   * 升级装备
   */
  upgradeEquipment(equipId: number): boolean {
    const equipment = this.player.equipments.get(equipId);
    if (equipment && equipment.currentLevel < equipment.maxLevel) {
      const price = equipment.getUpgradePrice();
      if (this.player.spendCoins(price)) {
        equipment.currentLevel++;
        return true;
      }
    }
    return false;
  }

  /**
   * 通关
   */
  passLevel(score: number): void {
    const level = this.getCurrentLevel();
    this.player.addScore(score);
    this.player.addCoins(level.reward);
    this.player.currentLevel++;
  }

  /**
   * 保存游戏数据
   */
  saveGameData(): string {
    const data: SaveData = {
      totalScore: this.player.totalScore,
      currentLevel: this.player.currentLevel,
      coins: this.player.coins,
      highestScore: this.player.highestScore,
      items: Array.from(this.player.items.entries()),
      equipments: Array.from(this.player.equipments.entries()).map((entry): EquipmentData => ({
        id: entry[0],
        currentLevel: entry[1].currentLevel
      }))
    };
    return JSON.stringify(data);
  }

  /**
   * 加载游戏数据
   */
  loadGameData(jsonStr: string): void {
    try {
      const data: SaveData = JSON.parse(jsonStr);
      this.player.totalScore = data.totalScore || 0;
      this.player.currentLevel = data.currentLevel || 1;
      this.player.coins = data.coins || 100;
      this.player.highestScore = data.highestScore || 0;
      if (data.items) {
        data.items.forEach((item: [number, number]) => {
          this.player.items.set(item[0], item[1]);
        });
      }
      if (data.equipments) {
        data.equipments.forEach((item: EquipmentData) => {
          const eq = this.player.equipments.get(item.id);
          if (eq) {
            eq.currentLevel = item.currentLevel;
          }
        });
      }
    } catch (e) {
      console.error('Failed to load game data:', e);
    }
  }
}
