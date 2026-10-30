import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The app's icon set: Lucide line icons, matching the Penpot design.
///
/// Screens refer to icons by these names, so swapping one is a one-line change.
abstract final class AppIcons {
  static const IconData add = LucideIcons.plus;
  static const IconData alarm = LucideIcons.alarmClock;
  static const IconData archive = LucideIcons.archive;
  static const IconData backspace = LucideIcons.delete;
  static const IconData backup = LucideIcons.databaseBackup;
  static const IconData bank = LucideIcons.landmark;
  static const IconData bolt = LucideIcons.zap;
  static const IconData bookmark = LucideIcons.bookmark;
  static const IconData bookmarkAdd = LucideIcons.bookmarkPlus;
  static const IconData bug = LucideIcons.bug;
  static const IconData calendar = LucideIcons.calendarDays;
  static const IconData camera = LucideIcons.camera;
  static const IconData car = LucideIcons.car;
  static const IconData cash = LucideIcons.banknote;
  static const IconData check = LucideIcons.check;
  static const IconData checkCircle = LucideIcons.circleCheck;
  static const IconData checkCircleFilled = LucideIcons.circleCheckBig;
  static const IconData chevronLeft = LucideIcons.chevronLeft;
  static const IconData chevronRight = LucideIcons.chevronRight;
  static const IconData close = LucideIcons.x;
  static const IconData cloudUpload = LucideIcons.cloudUpload;
  static const IconData copy = LucideIcons.copy;
  static const IconData creditCard = LucideIcons.creditCard;
  static const IconData currency = LucideIcons.coins;
  static const IconData delete = LucideIcons.trash2;
  static const IconData document = LucideIcons.fileText;
  static const IconData download = LucideIcons.download;
  static const IconData dragHandle = LucideIcons.gripVertical;
  static const IconData edit = LucideIcons.pencil;
  static const IconData encryption = LucideIcons.lockKeyhole;
  static const IconData entertainment = LucideIcons.circlePlay;
  static const IconData error = LucideIcons.circleAlert;
  static const IconData event = LucideIcons.calendar;
  static const IconData eventBusy = LucideIcons.calendarX;
  static const IconData eventRepeat = LucideIcons.calendarSync;
  static const IconData expandLess = LucideIcons.chevronUp;
  static const IconData expandMore = LucideIcons.chevronDown;
  static const IconData filter = LucideIcons.funnel;
  static const IconData fingerprint = LucideIcons.fingerprint;
  static const IconData food = LucideIcons.utensils;
  static const IconData gallery = LucideIcons.images;
  static const IconData gem = LucideIcons.gem;
  static const IconData gift = LucideIcons.gift;
  static const IconData grid = LucideIcons.layoutGrid;
  static const IconData health = LucideIcons.heart;
  static const IconData hidden = LucideIcons.eyeOff;
  static const IconData history = LucideIcons.history;
  static const IconData home = LucideIcons.house;
  static const IconData image = LucideIcons.image;
  static const IconData info = LucideIcons.info;
  static const IconData insights = LucideIcons.chartPie;
  static const IconData locationPin = LucideIcons.mapPin;
  static const IconData lock = LucideIcons.lock;
  static const IconData map = LucideIcons.map;
  static const IconData more = LucideIcons.ellipsisVertical;
  static const IconData myLocation = LucideIcons.locateFixed;
  static const IconData notifications = LucideIcons.bell;
  static const IconData bellRing = LucideIcons.bellRing;
  static const IconData alarmAdd = LucideIcons.alarmClockPlus;
  static const IconData alarmOn = LucideIcons.alarmClockCheck;
  static const IconData offline = LucideIcons.wifiOff;
  static const IconData openExternal = LucideIcons.externalLink;
  static const IconData pdf = LucideIcons.fileText;
  static const IconData people = LucideIcons.users;
  static const IconData person = LucideIcons.user;
  static const IconData pieChart = LucideIcons.chartPie;
  static const IconData pin = LucideIcons.rectangleEllipsis;
  static const IconData place = LucideIcons.mapPin;
  static const IconData privacy = LucideIcons.shieldCheck;
  static const IconData receipt = LucideIcons.receipt;
  static const IconData repeat = LucideIcons.repeat;
  static const IconData restore = LucideIcons.rotateCcw;
  static const IconData savings = LucideIcons.piggyBank;
  static const IconData search = LucideIcons.search;
  static const IconData searchOff = LucideIcons.searchX;
  static const IconData send = LucideIcons.send;
  static const IconData share = LucideIcons.share;
  static const IconData shield = LucideIcons.shield;
  static const IconData shopping = LucideIcons.shoppingBag;
  static const IconData sms = LucideIcons.messageSquareText;
  static const IconData sort = LucideIcons.arrowUpDown;
  static const IconData spreadsheet = LucideIcons.sheet;
  static const IconData time = LucideIcons.clock;
  static const IconData travel = LucideIcons.plane;
  static const IconData trendingUp = LucideIcons.trendingUp;
  static const IconData unarchive = LucideIcons.archiveRestore;
  static const IconData upload = LucideIcons.upload;
  static const IconData wallet = LucideIcons.wallet;
  static const IconData warning = LucideIcons.triangleAlert;
  static const IconData wave = LucideIcons.hand;

  /// Every icon above, for tests and previews.
  static List<IconData> get all => const [
    add,
    alarm,
    archive,
    backspace,
    backup,
    bank,
    bolt,
    bookmark,
    bookmarkAdd,
    bug,
    calendar,
    camera,
    car,
    cash,
    check,
    checkCircle,
    checkCircleFilled,
    chevronLeft,
    chevronRight,
    close,
    cloudUpload,
    copy,
    creditCard,
    currency,
    delete,
    document,
    download,
    dragHandle,
    edit,
    encryption,
    entertainment,
    error,
    event,
    eventBusy,
    eventRepeat,
    expandLess,
    expandMore,
    filter,
    fingerprint,
    food,
    gallery,
    gem,
    gift,
    grid,
    health,
    hidden,
    history,
    home,
    image,
    info,
    insights,
    locationPin,
    lock,
    map,
    more,
    myLocation,
    notifications,
    offline,
    openExternal,
    pdf,
    people,
    person,
    pieChart,
    pin,
    place,
    privacy,
    receipt,
    repeat,
    restore,
    savings,
    search,
    searchOff,
    send,
    share,
    shield,
    shopping,
    sms,
    sort,
    spreadsheet,
    time,
    travel,
    trendingUp,
    unarchive,
    upload,
    wallet,
    warning,
    wave,
    bellRing,
    alarmAdd,
    alarmOn,
  ];
}
