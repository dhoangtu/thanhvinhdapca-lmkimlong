% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 68"
  composer = "Lm. Kim Long"
  tagline = ##f
}

% mã nguồn cho những chức năng chưa hỗ trợ trong phiên bản lilypond hiện tại
% cung cấp bởi cộng đồng lilypond khi gửi email đến lilypond-user@gnu.org
% in số phiên khúc trên mỗi dòng
#(define (add-grob-definition grob-name grob-entry)
     (set! all-grob-descriptions
           (cons ((@@ (lily) completize-grob-entry)
                  (cons grob-name grob-entry))
                 all-grob-descriptions)))

#(add-grob-definition
    'StanzaNumberSpanner
    `((direction . ,LEFT)
      (font-series . bold)
      (padding . 1.0)
      (side-axis . ,X)
      (stencil . ,ly:text-interface::print)
      (X-offset . ,ly:side-position-interface::x-aligned-side)
      (Y-extent . ,grob::always-Y-extent-from-stencil)
      (meta . ((class . Spanner)
               (interfaces . (font-interface
                              side-position-interface
                              stanza-number-interface
                              text-interface))))))

\layout {
    \context {
      \Global
      \grobdescriptions #all-grob-descriptions
    }
    \context {
      \Score
      \remove Stanza_number_align_engraver
      \consists
        #(lambda (context)
           (let ((texts '())
                 (syllables '()))
             (make-engraver
              (acknowledgers
               ((stanza-number-interface engraver grob source-engraver)
                  (set! texts (cons grob texts)))
               ((lyric-syllable-interface engraver grob source-engraver)
                  (set! syllables (cons grob syllables))))
              ((stop-translation-timestep engraver)
                 (for-each
                  (lambda (text)
                    (for-each
                     (lambda (syllable)
                       (ly:pointer-group-interface::add-grob
                        text
                        'side-support-elements
                        syllable))
                     syllables))
                  texts)
                 (set! syllables '())))))
    }
    \context {
      \Lyrics
      \remove Stanza_number_engraver
      \consists
        #(lambda (context)
           (let ((text #f)
                 (last-stanza #f))
             (make-engraver
              ((process-music engraver)
                 (let ((stanza (ly:context-property context 'stanza #f)))
                   (if (and stanza (not (equal? stanza last-stanza)))
                       (let ((column (ly:context-property context
'currentCommandColumn)))
                         (set! last-stanza stanza)
                         (if text
                             (ly:spanner-set-bound! text RIGHT column))
                         (set! text (ly:engraver-make-grob engraver
'StanzaNumberSpanner '()))
                         (ly:grob-set-property! text 'text stanza)
                         (ly:spanner-set-bound! text LEFT column)))))
              ((finalize engraver)
                 (if text
                     (let ((column (ly:context-property context
'currentCommandColumn)))
                       (ly:spanner-set-bound! text RIGHT column)))))))
      \override StanzaNumberSpanner.horizon-padding = 10000
    }
}

stanzaReminderOff =
  \temporary \override StanzaNumberSpanner.after-line-breaking =
     #(lambda (grob)
        ;; Can be replaced with (not (first-broken-spanner? grob)) in 2.23.
        (if (let ((siblings (ly:spanner-broken-into (ly:grob-original grob))))
              (and (pair? siblings)
                   (not (eq? grob (car siblings)))))
            (ly:grob-suicide! grob)))

stanzaReminderOn = \undo \stanzaReminderOff
% kết thúc mã nguồn

% Nhạc
nhacPhanMot = \relative c' {
  \key f \major
  \time 2/4
  f8. a16 bf8 bf |
  g4. f8 |
  g a g (f) |
  e2 |
  d8. d16 f8 g |
  a4. f8 |
  f bf a (g) |
  g2 |
  f8. a16 f (e) d8 |
  e4. a,8 |
  e' e g16 (a) c,8 |
  d4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      a'4. g8 |
      f f g (f) |
      e4. e8 |
      g a e4
    }
    {
      f4. f8 |
      d d e (d) |
      a4. a8 |
      e' d cs4
    }
  >>
  d2 ~ |
  d4 r \bar "|."
}

nhacPhanBa = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 d8 |
  d d
  <<
    {
      a'16 (bf) a8 |
      g4 f8 e |
      a4. a8 |
      a f e4
    }
    {
      f16 (g) f8 |
      e4 d8 a |
      f'4. f8 |
      f d cs4
    }
  >>
  d2 ~ |
  d4 r \bar "|."
}

nhacPhanBon = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      a'4. a8 |
      a bf
    }
    {
      f4. f8 |
      d g
    }
  >>
  <<
    {
      \voiceOne
      a8 (g)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      f4
    }
  >>
  \oneVoice
  <<
    {
      g4. g8 |
      f f g e
    }
    {
      e4. e8 |
      d d e cs
    }
  >>
  d2 ~ |
  d4 r \bar "|."
}

nhacPhanNam = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      a'4. a8 |
      f bf
    }
    {
      f4. f8 |
      d g
    }
  >>
  <<
    {
      \voiceOne
      a8 (g)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      f4
    }
  >>
  \oneVoice
  <<
    {
      g4. g8 |
      f f g (f) |
      e4. g8 |
      f e f a
    }
    {
      e4. e8 |
      d d e (d) |
      a4. bf8 |
      a a d cs
    }
  >>
  d2 ~ |
  d4 r \bar "|."
}

nhacPhanSau = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      a'4. f8 |
      e f g (a)
    }
    {
      f4. d8 |
      a d e (cs)
    }
  >>
  d2 ~ |
  d4 r \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Này con cứ lún sâu, thật sâu giữa vũng lầy.
      Tựa vào đâu cho vững?
      Và này tấm thân con dòng nước thẳm nhận sâu,
      và muôn con sóng cuộn trôi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Kẻ vô cớ ghét con nhiều hơn tóc trên đầu,
      Bọn thù con vô lý lại mạnh thế hơn con.
      Chẳng lấy chi của ai mà nay con phải đền bồi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Chịu khinh ghét nhuốc nhơ, thực ra cũng bởi Ngài.
      Bị người thân chê chối, bị đoạn nghĩa anh em.
      Nhà Chúa lo nhiệt tâm mà thân con hững tủi nhục.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Lời kêu khấn, Chúa ơi, vì ân nghĩa cao dầy,
      vì Ngài luôn trung tín, thẩm nhận, đoái thi ân.
      Vì trắc ẩn từ bi, Ngài thương trông đến nhậm lời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Nguyện xin Chúa kéo con khỏi sa xuống vũng lầy,
      khỏi bàn tay hung ác, khỏi dòng nước thẳm sâu.
      Kìa sóng cả trào dâng vực sâu đang há đợi chờ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Tìm thân hữu cảm thông mà đâu thấy ai nào,
      Đợi ủi an đoi chút mà rồi cũng uổng công.
      Mật đắng thay của ăn, họng khô cho giấm giải lao.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Phận con quá đớn đau, nguyện xin Chúa bảo toàn,
      phù trợ, gia ân phúc, hầy miệng lưỡi con đay
      sẽ hát câu tạ ơn, ngợi ca danh thánh của Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Bạn khiêm ái ngước trông mà vui sướng reo mừng,
      Ngươi tìm Tôn nhan Chúa lòng rộn rã hân hoan,
      Vì Chúa nghe bần nhân, chẳng quên thân hữu rục tù.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Bạn khiêm ái ngước trông mà vui sướng reo mừng,
      Người tìm Tôn nhan Chúa lòng rộn rã hân hoan,
      Trời đất nhảy mừng lên, đại dương mau tán tụng Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Này Thiên Chúa cứu nguy và cho tái xây dựng,
      Từ miền Si -- on tới thành thị khắp Giu -- đa
      Gọi đến cho định cư hẻ yêu danh thanh của Ngài.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa, xin nhậm lời con nguyện vì ân nghĩa cao dầy.
}

loiPhanBa = \lyricmode {
  Người nghèo hèn hãy vui lên, kẻ tìm Chúa hãy phấn khởi reo mừng.
}

loiPhanBon = \lyricmode {
  Lạy Chúa, đây là lúc thi ân, xin nhậm lời con nguyện cầu.
}

loiPhanNam = \lyricmode {
  Lạy Chúa, đây là lúc thi ân,
  xin nhậm lời con nguyện theo lượng từ bi của Ngài.
}

loiPhanSau = \lyricmode {
  Vì Chúa nhậm lời kẻ khó nghèo.
}


% Dàn trang
\paper {
  #(set-paper-size "a5")
  top-margin = 3\mm
  bottom-margin = 3\mm
  left-margin = 3\mm
  right-margin = 3\mm
  indent = #0
  #(define fonts
	 (make-pango-font-tree "Deja Vu Serif Condensed"
	 		       "Deja Vu Serif Condensed"
			       "Deja Vu Serif Condensed"
			       (/ 20 20)))
  print-page-number = ##f
  ragged-bottom = ##t
}

\markup {
  \vspace #1
  %\fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
        \line { \small "-t4 tuần Thánh: câu 3, 6, 7, 8 + Đ.4" }
        \line { \small "-Cn A /12TN: câu 3, 4, 9 + Đ.1" }
        \line { \small "-Cn C /15TN: câu 4, 7, 8, 10 + Đ.2" }
        \line { \small "-t3 l /15TN: câu 1, 4, 7, 8 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-t6 c /17TN: câu 2, 3, 4 + Đ.1" }
        \line { \small "-t7 c /17TN: câu 5, 7, 8 + Đ.3" }
        \line { \small "-t7 l /26TN: câu 9, 10 + Đ.5" }
        \line { \small "-t2 l /31TN: câu 7, 8, 10 + Đ.1" }
      }
    }
  %}
}

\score {
  <<
    \new Staff <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanMot
        }
      \new Lyrics \lyricsto beSop \loiPhanMot
    >>
  >>
  \layout {
    \override Lyrics.LyricSpace.minimum-distance = #1
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.1" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanHai
        }
      \new Lyrics \lyricsto beSop \loiPhanHai
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.6
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.2" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanBa
        }
      \new Lyrics \lyricsto beSop \loiPhanBa
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.45
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.3" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanBon
        }
      \new Lyrics \lyricsto beSop \loiPhanBon
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.45
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.4" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanNam
        }
      \new Lyrics \lyricsto beSop \loiPhanNam
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.45
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.5" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanSau
        }
      \new Lyrics \lyricsto beSop \loiPhanSau
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.45
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
