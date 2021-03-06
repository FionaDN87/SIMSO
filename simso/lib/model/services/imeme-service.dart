import 'package:simso/model/entities/meme-model.dart';
import 'package:simso/model/entities/user-model.dart';

abstract class IMemeService {
  Future<List<Meme>> getMemes(String uid);
  Future<void> addMeme(Meme meme);
  Future<void> updateMeme(Meme meme);
  Future<void> deleteMeme(String uid);
  Future<List<Meme>> contentMemeList(bool friends, UserModel user);
}