import 'dart:async';
import 'dart:io' as io;
import 'section.dart';
import 'tag.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper{

  static Database _db;

  Future<Database> get db async {
    if(_db != null)
      return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "categories.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE Section(id INTEGER PRIMARY KEY, title TEXT, slug TEXT, count INTEGER )");
    await db.execute("CREATE TABLE Tag(id INTEGER PRIMARY KEY, title TEXT, slug TEXT, count INTEGER )");
    for (SectionModel section in SectionModel.baseSections) {
      saveSection(section);
    }
  }
  
  closeDB() async {
    _db.close();
  }
  
  Future<List<SectionModel>> getSections() async {
    var dbClient = await db;
    List<Map> list = await dbClient.transaction((txn) async {
      return txn.query("Section");
    });
    List<SectionModel> sections = new List();
    for (int i = 0; i < list.length; i++) {
      sections.add(new SectionModel(list[i]["title"], list[i]["slug"], list[i]['count']));
    }

    return sections;
  }

  Future<List<TagModel>> getTags() async {
    var dbClient = await db;
    List<Map> list = await dbClient.transaction((txn) async {
      return txn.query("Tag");
    });

    List<TagModel> tags = new List();
    for (int i = 0; i < list.length; i++) {
      tags.add(new TagModel(list[i]["title"], list[i]["slug"], list[i]['count']));
    }
    return tags;
  }

  Future<bool> isSectionSaved(SectionModel section) async {
    var dbClient = await db;
    List list =  await dbClient.transaction((txn) async {
      return txn.query("Section", where:"slug = ?", whereArgs: [section.slug]);
    });
    return list.length > 0;
  }

   Future<bool> isTagSaved(TagModel tag) async {
    var dbClient = await db;
    List list = await dbClient.transaction((txn) async {
      return txn.query("Tag", where: "slug = ?", whereArgs: [tag.slug]);
    });
    return list.length > 0;
  }

  void deleteSection(SectionModel section) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.delete("Section", where: "slug = ?", whereArgs: [section.slug]);
    });
  }

  void deleteTag(TagModel tag) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.delete("Tag", where: "slug = ?", whereArgs: [tag.slug]);
    });
  }
  
  void saveSection(SectionModel section) async {
    if (!(await isSectionSaved(section))) {
      var dbClient = await db;
      await dbClient.transaction((txn) async {
        return await txn.rawInsert(
          'INSERT INTO Section(title, slug, count ) VALUES(' +
              '\'' +
              section.title +
              '\'' +
              ',' +
              '\'' +
              section.slug +
              '\'' +
              ',' +
              '\'' +
              section.count.toString() + 
              '\'' + 
              ')');
      });
    }
  }

  void saveTag(TagModel tag) async {
    if (!(await isTagSaved(tag))) {
      var dbClient = await db;
      await dbClient.transaction((txn) async {
        return await txn.rawInsert(
          'INSERT INTO Tag(title, slug, count ) VALUES(' +
              '\'' +
              tag.title +
              '\'' +
              ',' +
              '\'' +
              tag.slug +
              '\'' +
              ',' +
              '\'' +
              tag.count.toString() + 
              '\'' + 
              ')');
      });
    }
  }


}