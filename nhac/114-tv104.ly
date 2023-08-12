% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 104"
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
  f8 (g) d c |
  a'8. f16 bf8 bf |
  g2 |
  g8 a f g |
  d8. c16 f8 g |
  a4 bf8 bf |
  g4.
  <<
    {
      \voiceOne
      g8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #1
      \parenthesize
      f8
    }
  >>
  \oneVoice
  f f g a |
  bf4 bf8 d |
  c4. g8 |
  g c
  \once \phrasingSlurDashed
  a \(g\) |
  f4 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 f8 (d) |
  c4
  <<
    {
      a'8 a |
      a4. a8 |
      bf8 g c e, |
      f2
    }
    {
      f8 f |
      f4. f8 |
      g e d c |
      a2
    }
  >>
  \bar "|."
}

nhacPhanBa = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 f8 (d) |
  c8.
  <<
    {
      a'16 g8 f |
      bf4 c8 e, |
      f2 ~ |
      f4 r
    }
    {
      f16 e8 ef |
      d4 c8 c |
      a2 ~ |
      a4 r
    }
  >>
  \bar "|."
}

nhacPhanBon = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 f8 (g) |
  d4. c8 |
  <<
    {
      a'4. bf8 |
      g4 c
    }
    {
      f,4. d8 |
      e4 e
    }
  >>
  f2 \bar "|."
}

nhacPhanNam = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 f8 (g) |
  d4. c8 |
  <<
    {
      a'4. bf8 |
      bf g c4
    }
    {
      f,4. g8 |
      g f e4
    }
  >>
  f2 \bar "|."
}

nhacPhanSau = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 f8 (g) |
  d4. c8 |
  <<
    {
      a'4. bf8 |
      g bf c c
    }
    {
      f,4. g8 |
      f e e e
    }
  >>
  f2 \bar "|."
}

nhacPhanBay = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 f8 (d) |
  c4.
  <<
    {
      a'8 |
      bf g c e, |
      f2 ~ |
      f4 r
    }
    {
      f8 |
      d d c c |
      a2 ~ |
      a4 r
    }
  >>
  \bar "|."
  
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Hãy cảm tạ Chúa, cầu khấn Thánh Danh.
      Loan báo kỳ công Ngài giữa muôn dân nước.
      Hát xướng lên theo nhịp đàn ngợi khen Chúa,
      và gẫm suy sự việc Chúa đã _ làm.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Hãy tự hào mãi vì có Thánh Danh.
      Ai những tìm kiếm Ngài hãy may vui sướng.
      Kiếm Chúa luôn, trông nhờ quyền uy tay Chúa
      và chẳng ngưng tìm diện kiến nhan _ Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Hãy cảm tạ Chúa, cầu khấn Thánh Danh.
      Loan báo kỳ công Ngài giữa muôn dân nước.
      Nhắc nhớ luôn muôn vàn kỳ công tay Chúa,
      mọi dấu thiêng, mọi điều Chúa ban _ truyền.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Hát lên mừng Chúa, đàn hãy tấu vang,
      suy gẫm mọi công trình Ngài đã tạo tác.
      Hãy nhớ luôn \markup { \italic "tự" } hào vì uy danh Chúa,
      hãy sướng vui, lòng kẻ kiếm trông _ Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Những ai cậy Chúa và dũng sức Ngài,
      luôn nhớ đừng khi ngừng tìm tôn nhan Chúa.
      Nhắc nhớ luôn muôn vàn kỳ công tay Chúa,
      mọi dấu thiêng, mọi điều Chúa ban _ truyền.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Hỡi nô bộc Chúa, dòng dõi Ap -- raham,
      con cháu Ngài tuyển chọn thuộc nhà Gia -- cop.
      Đức Chúa ta muôn đời Ngài là Thiên Chúa,
      Ngài quyết chi, địa cầu phải tuân _ hành.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Những điều thề hứa Ngài vẫn nhớ luôn,
      Gia ước Ngài đã lập ngàn đời kiên vững.
      Chính Chúa thương đoan thề cùng I -- sa -- ác,
      Hiệp ước xưa Ngài lập với A -- a -- ron.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa cho nạn đói tràn tới khắp nơi,
      đây đó cạn lương thực để nuôi dân chúng.
      Chúa đã thương sai một người ra đi trước,
      là Giu -- se kẻ bị bán như tôi đòi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Đã bị xiềng xích nặng trĩu ở chân,
      nhưng chúng còn tra cùm vào cổ ông nữa.
      Mãi tới khi linh nghiệm lời ông tiên đoán,
      Lời Chúa nay là bằng chứng ông vô tội.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Chính vị hoàng đế, thủ lãnh các dân
      cho tháo cởi gông cùm và tha ông gấp,
      Cất nhắc lên trong triều làm quan tể tướng,
      quản lý luôn sản nghiệp của cung _ đình.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      Khiến dân Ngài dũng mạnh thắng đối phương,
      Dân số họ mỗi ngày một tăng thêm mãi,
      Khiến đối phương thay lòng và đâm ghen ghét,
      bàn tính nhau làm hại chống dân _ Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "12."
      \override Lyrics.LyricText.font-shape = #'italic
      Phái nô bộc Chúa là chính Mô -- sê,
      sai kẻ Ngài tuyển chọn là A -- a -- ron,
      Đến báo tin báo điềm là của Thiên Chúa,
      cùng dấu thiêng trừng phạt khắp Ai _ Cập.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "13."
      Trưởng nam toàn xứ bị giết khắp nơi.
      Đây những gì tinh nhuệ của cả dân nước.
      Chúa khiến dân đem vàng bạc ra đi gấp,
      từng ấy chi, chẳng hề có ai xiêu lạc.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "14."
      \override Lyrics.LyricText.font-shape = #'italic
      Bời vì Ngài nhớ lời Thánh ước xưa,
      cho Ap -- ra -- ham là bầy tôi của Chúa.
      Chúa dẫn đưa dân Ngài chọn ra đi đó.
      họ sướng vui rộn ràng tiếng reo _ hò.
    }
  >>
}

loiPhanHai = \lyricmode {
  Muôn đời Chúa vẫn nhớ Giao ước Ngài đã lập ra.
}

loiPhanBa = \lyricmode {
  Tâm hồn những ai tìm Chúa hãy mừng vui.
}

loiPhanBon = \lyricmode {
  Hãy luôn tìm kiếm thánh nhan Chúa Trời.
}

loiPhanNam = \lyricmode {
  Những ai tìm Chúa hãy phấn khởi nức lòng.
}

loiPhanSau = \lyricmode {
  Hãy luôn tưởng nhớ những kỳ công Chúa đã làm.
}

loiPhanBay = \lyricmode {
  Địa cầu chan chứa phúc lộc của Ngài.
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
  page-count = 3
}

\markup {
  \vspace #1
  %\fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
        \line { \small "-t4 l /1TN: câu 1, 2, 6, 7 + Đ.1" }
        \line { \small "-t4 l /12TN: câu 1, 2, 6, 7 + Đ.1" }
        \line { \small "-t4 c /14TN: câu 1, 2, 6 + Đ.3" }
        \line { \small "-t5 l /14TN: câu 8, 9, 10 + Đ.5" }
        \line { \small "-t7 l /14TN: câu 1, 2, 6 + Đ.2" }
        \line { \small "-t5 l /15TN: câu 1, 7, 11, 12 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t7 c /27TN: câu 4, 5, 6 + Đ.1" }
        \line { \small "-t7 l /28TN: câu 6, 7, 14 + Đ.1" }
        \line { \small "-t5 l /31TN: câu 4, 5, 6 + Đ.4" }
        \line { \small "-t7 l /32TN: câu 4, 12, 14 + Đ.5" }
        \line { \small "-t6 /2MC: câu 8, 9, 10 + Đ.5" }
        \line { \small "-t5 /5MC: câu 5, 6, 7 + Đ.1" }
        \line { \small "-t4 /PS: câu 1, 2, 6, 7 + Đ.5" }
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
