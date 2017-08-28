import scala.collection.mutable

object Extractors {
  def question(items: List[Result], questionId: Int): Double = {
    var qs = mutable.ListBuffer[String]()
    items foreach { item =>
      if (item.content.surveys.length>0)
        item.content.surveys(0) foreach { si =>
          if (si.question==questionId)
            qs += si.value.toString
        }
    }
    if (qs.isEmpty)
      return 0.0
    return qs.map(_.toDouble).max
  }

  def session(res: List[Result], sessionId: Int): Boolean = {
    res foreach { item =>
      item.content.timestamps foreach { ts =>
        if (ts.action=="finished" && ts.session==sessionId)
          return true
      }
    }
    return false
  }


  def profile(res: List[Result]): Option[ProfileItem] = {
    res foreach { item =>
      val profile = item.content.profile
      if (profile.name.getOrElse("").trim.size>0 && profile.emailPhone.getOrElse("").trim.size>0)
        return Option(profile)
    }
    return None
  }
}