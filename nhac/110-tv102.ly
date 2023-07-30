% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 102"
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
nhacPhanMot = \relative c'' {
  \key f \major
  \time 2/4
  \partial 4 \tuplet 3/2 { a8 g
    <<
        {
          \voiceOne
          a
        }
        \new Voice = "splitpart" {
          \voiceTwo
          \once \override NoteColumn.force-hshift = #1
          \parenthesize
          g
        }
    >>
  } |
  \oneVoice
  a8. a16 \tuplet 3/2 { d,8 f g } |
  a4. f16
  <<
    {
      \voiceOne
      g
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #1
      \parenthesize
      f
    }
  >> |
  \oneVoice
  g4 \tuplet 3/2 { a8 g f } |
  e4 \tuplet 3/2 { a8 g a } |
  a8. a16 \tuplet 3/2 { d,8 f g } |
  a4. e16 e |
  g4 \tuplet 3/2 { a8 f e } |
  d4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 d16 a' |
  a8. bf16 \tuplet 3/2 { g8 a c } |
  d2 ~ |
  d4 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 d16 g, |
  bf4 \tuplet 3/2 { e,8 g e } |
  d2 ~ |
  d4 \bar "|."
}

nhacPhanBon = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 d16 g, |
  bf4 \tuplet 3/2 { e,8 g g } |
  a4. f16 f |
  f8. e16 \tuplet 3/2 { a8 c, c } |
  d4 \bar "|."
}

nhacPhanNam = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a16 f |
  bf4 \tuplet 3/2 { g8 g a } |
  a4 \tuplet 3/2 { f8 g f } |
  e4 \tuplet 3/2 { a8 c, e } |
  d4 \bar "|."
}

nhacPhanSau = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a16 a |
  d,4. f16 (g) |
  a8. a16 \tuplet 3/2 { g8 a c } |
  d2 ~ |
  d4 \bar "|."
}

nhacPhanBay = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a16 a |
  a8. d,16 \tuplet 3/2 { d8 f g } |
  a4. a16 f |
  e4 \tuplet 3/2 { g8 c, e } |
  d4 \bar "|."
}

nhacPhanTam = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a16 a |
  a8. d,16 \tuplet 3/2 { f8 e g } |
  a4 \tuplet 3/2 { g8 f a } |
  g4 \tuplet 3/2 { a8 e f } |
  d4 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Linh hồn tôi ơi, hãy ngợi khen Thiên Chúa,
      Toàn thân tôi tán dương danh Ngài.
      Linh hồn tôi ơi, hãy ngợi khen Thiên Chúa,
      và đừng quên các ân huệ Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Bao tội khiên ngươi Chúa dủ tình tha thứ,
      và \markup { \underline "còn" } thương chữa bao tật nguyền.
      Tay Ngài đưa ngươi thoát mồ sâu tăm tối,
      và rộng ban nghĩa ân hải hà.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Bênh quyền \markup { \underline "lợi" } cho những kẻ bị uy hiếp,
      và \markup { \underline "thực" } thi lẽ công minh hoài.
      Soi dậy Mô -- sê biết đường ngay nẻo chính,
      và thần dân thấy uy công Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Xưng tụng uy danh Chúa từ bi nhân ái,
      chậm \markup { \underline "giận" } nhưng mến thương khôn lường.
      Không xử phân theo những gì ta sai lỗi,
      chẳng phạt ta đúng như tội tình.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Đâu Ngài luôn luôn trách hờn rầy là mãi,
      nào đang tâm oán ta miên trường.
      Không xử phân theo những gì ta sai lỗi,
      chẳng phạt ta đúng như tội tình.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Không xử phân theo những gì ta sai lỗi,
      chẳng \markup { \underline "phạt" } ta đúng như tội tình.
      Như trời cao xa trổi vượt trên mặt đất,
      Ngài rộng thương kẻ tôn sợ Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Như trời cao xa trổi vượt trên mặt đất,
      Ngài \markup { \underline "rộng" } thương kẻ tôn sợ Ngài.
      Bao tội khiên ta, Chúa liệng xa ta mãi,
      tựa phương đông cách xa phương đoài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Bao tội khiên ta, Chúa liệng xa ta mãi,
      tựa phương đông cách xa phương đoài.
      Như người Cha luôn hết tình thương con cái,
      Ngài chạnh thương kẻ suy tôn Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Như người cha luôn hết tình thương con cái,
      Ngài yêu thương kẻ suy tôn Ngài.
      Đâu Ngài quyên ta đã được nặn ra đó,
      chỉ là thân cát bụi đơn hèn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Thân phận \markup { \underline "phù" } sinh,
      tháng ngày trôi mau quá,
      tựa bông hoa nở trên nương đồng,
      mau lẹ tiêu tan lúc vừa gặp cơn gió,
      cội nguồn xưa chẳng nhận ra mình.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      Muôn đời yêu thương vẫn còn luôn chan chứa,
      dành cho ai vững tâm tin thờ.
      Phân xử công minh với cả đời con cháu,
      và kẻ luôn giữ minh giao Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "12."
      \override Lyrics.LyricText.font-shape = #'italic
      Trên trời cao xanh, Chúa đặt để ngai báu,
      và lên ngôi bá chủ muôn loài.
      Ca tụng lên đi, hỡi toàn thể thiên sứ,
      hầu cận ngai để tuân lệnh Ngài.
    }
  >>
}

loiPhanHai = \lyricmode {
  Hồn tôi hỡi, hãy ngợi khen Thiên Chúa.
}

loiPhanBa = \lyricmode {
  Chúa là Đấng từ bi nhân hậu.
}

loiPhanBon = \lyricmode {
  Chúa là Đấng từ bi nhân ái,
  Ngài chậm giận và rất giầu tình thương.
}

loiPhanNam = \lyricmode {
  Ân tình Chúa vạn đại thiên thu
  dành cho kẻ nào hết dạ kính tôn.
}

loiPhanSau = \lyricmode {
  Chúa đã đặt ngai báu trên trời xanh cao vút.
}

loiPhanBay = \lyricmode {
  Như người cha chạnh lòng thương con cái,
  Chúa chạnh lòng thương kẻ kính tôn.
}

loiPhanTam = \lyricmode {
  Chúa không cứ tội ta mà minh xét,
  không trả báo ta xứng mọi lỗi lầm.
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
        \line { \small "-t4 /MV: câu 1, 2, 4 + Đ.1" }
        \line { \small "-t4 l /4TN: câu 1, 9, 11 + Đ.4" }
        \line { \small "-CN A /7TN: câu 1, 2, 4, 8 + Đ.2" }
        \line { \small "-t7 l /7TN: câu 9, 10, 11 + Đ.4" }
        \line { \small "-CN C /7TN: câu 1, 2, 4, 8 + Đ.2" }
        \line { \small "-t6 c /7TN: câu 1, 2, 4, 7 + Đ.2" }
        \line { \small "-CN B /8TN: câu 1, 2, 4, 8 + Đ.2" }
        \line { \small "-Lễ T.Tâm A: câu 1, 2, 3, 4 + Đ.4" }
        \line { \small "-t7 l /10TN: câu 1, 2, 4, 7 + Đ.4" }
        \line { \small "-t2 l /13TN: câu 1, 2, 4, 7 + Đ.4" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-t4 l /15TN: câu 1, 2, 3 + Đ.2" }
        \line { \small "-t3 l /17TN: câu 3, 6, 7 + Đ.2" }
        \line { \small "-CN A /24TN: câu 1, 2, 5, 7 + Đ.3" }
        \line { \small "-t7 /2MC: câu 1, 2, 5, 7 + Đ.2" }
        \line { \small "-Cn C /3MC: câu 1, 2, 3, 4 + Đ.2" }
        \line { \small "-CN B /7PS: câu 1, 8, 12 + Đ.5" }
        \line { \small "-t6 /7PS: câu 1, 8, 12 + Đ.5" }
        \line { \small "-Hôn phối: câu 1, 4, 11 + Đ.4" }
        \line { \small "-Trao kinh Lạy Cha: câu 1, 4, 7, 9 + Đ.6" }
        \line { \small "-Xin tha tội: câu 1, 2, 4 + Đ.1 hoặc Đ.7" }
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

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.6" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanBay
        }
      \new Lyrics \lyricsto beSop \loiPhanBay
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
      instrumentName = \markup { \bold "Đ.7" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanTam
        }
      \new Lyrics \lyricsto beSop \loiPhanTam
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
