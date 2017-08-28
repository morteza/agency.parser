import java.time.LocalDateTime
import java.util.Date

case class Result(
                   submittedAt: LocalDateTime,
                   subjectId: String,
                   code: String,
                   content: Content
                 )


case class Content(
                  timestamps: List[TimestampItem],
                  surveys: List[SurveyItem],
                  profile: ProfileItem,
                  feedbacks: List[FeedbackItem]
                  )

case class TimestampItem(
                    session: Int,
                    action: String,
                    timestamp: Long
                    )

case class SurveyItem(question: Int, value: String)

case class ProfileItem(name: Option[String], emailPhone: Option[String])

case class FeedbackItem()
