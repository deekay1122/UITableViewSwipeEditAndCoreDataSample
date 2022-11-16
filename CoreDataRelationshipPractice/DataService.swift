//
//  DataService.swift
//  CoreDataRelationshipPractice
//
//  Created by Daisaku Ejiri on 2022/11/15.
//

import Foundation
import CoreData
import RxRelay

class DataService {
  
  // singleton
  public static let shared = DataService()
  
  private init() {
    if let project = getProject() {
      projectRelay.accept(project)
    }
  }
  
  // core data
  let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  var projectRelay: BehaviorRelay<Project?> = BehaviorRelay(value: nil)
  
  private func getProject() -> Project? {
    let request = Project.fetchRequest()
    let predicate = NSPredicate(format: "title == %@", "parent")
    request.predicate = predicate
    do {
      let result = try managedContext.fetch(request)
      if result.isEmpty {
        let project = Project(context: managedContext)
        project.title = "parent"
        try managedContext.save()
        return project
      } else {
        let project = result.first!
        return project
      }
    } catch {
      print("error getting project in getProject()")
    }
    return nil
  }
  
  public func addNewSong(title: String) {
    let project = getProject()
    let newSong = Song(context: managedContext)
    newSong.title = title
    project?.addToSongs(newSong)
    do {
      try managedContext.save()
    } catch {
      print("error when saving a newSong in core data: \(error)")
    }
    projectRelay.accept(project)
  }
  
  public func updateReorderedSongs(songs: [Song]) {
    guard let project = getProject() else { fatalError("error getting project in updateReorderedSongs()") }
    project.songs = NSOrderedSet(array: songs)
    do {
      try managedContext.save()
    } catch {
      print("error saving reorderedSongs in core data")
    }
    projectRelay.accept(project)
  }
  
  public func deleteSongAndUpdate(song: Song, songs: [Song]) {
    var tempSongs = songs
    if songs.isEmpty {
      let newSong = Song(context: managedContext)
      newSong.title = "New Song"
      tempSongs.append(newSong)
    }
    guard let project = getProject() else { fatalError("error when getting project in deleteSongAndUpdate()") }
    project.songs = NSOrderedSet(array: tempSongs)
    managedContext.delete(song)
    do {
      try managedContext.save()
    } catch {
      print("error when saving in deleteSongAndUpdate()")
    }
    projectRelay.accept(project)
  }
  
  public func checkUnique(title: String) -> Bool {
    let request = Song.fetchRequest()
    let predicate = NSPredicate(format: "title == %@", title)
    request.predicate = predicate
    do {
      let result = try managedContext.fetch(request)
      return result.isEmpty
    } catch {
      print("error when fetching a song/songs in checkUnique()")
    }
    return true
  }
}
