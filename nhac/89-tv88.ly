% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 88"
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
  \partial 8 f16 g |
  a4. g8 |
  e4 \tuplet 3/2 { f8 f d } |
  c4 r8 c |
  a'8. f16 \tuplet 3/2 { a8 bf a } |
  g8. g16
  \tuplet 3/2 {
    <<
      {
        \voiceOne
        g8
      }
      \new Voice = "splitpart" {
        \voiceTwo
        \once \override NoteColumn.force-hshift = #-1
        \parenthesize
        c8
      }
    >>
    c e, }
  %\oneVoice
  f4 r8 c16 a' |
  a4. f16 a |
  bf8. bf16 \tuplet 3/2 { g8 d' c } |
  c4. c16
  <<
    {
      \voiceOne
      c
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #-1
      \parenthesize
      e,16
    }
  >>
  \oneVoice
  e4.
  <<
    {
      \voiceOne
      e8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #2.5
      \parenthesize
      g8
    }
  >>
  \oneVoice
  a8.
  <<
    {
      \voiceOne
      a16
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #1
      \parenthesize
      g16
    }
  >>
  \oneVoice
  \tuplet 3/2 { c,8 g' g } |
  f2 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key f \major
  \time 2/4
  <<
    {
      a4. bf16 a |
      g4 \tuplet 3/2 { g8 a bf } |
      c4. a16 g |
      f4 r8 \bar "|."
    }
    {
      f4. g16 f |
      e4 \tuplet 3/2 { e8 f g } |
      a4. c,16 bf |
      a4 r8
    }
  >>
}

nhacPhanBa = \relative c'' {
  \key f \major
  \time 2/4
  <<
    {
      a4. bf8 |
      g a4 bf8 |
      c4 \tuplet 3/2 { c,8 g' e } |
      f4 r8 \bar "|."
    }
    {
      f4. g8 |
      e f4 f8 |
      e4 \tuplet 3/2 { c8 bf c } |
      a4 r8
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key f \major
  \time 2/4
  <<
    {
      a4 \tuplet 3/2 { bf8 a g } |
      d8. c16 \tuplet 3/2 { g'8 e g } |
      f2 ~ |
      f4 r8 \bar "|."
    }
    {
      f4 \tuplet 3/2 { g8 f c } |
      bf8. a16 \tuplet 3/2 { bf8 c bf } |
      a2 ~ |
      a4 r8
    }
  >>
}

nhacPhanNam = \relative c'' {
  \key f \major
  \time 2/4
  <<
    {
      a4 \tuplet 3/2 { bf8 a g } |
      d4 \tuplet 3/2 { c8 a' g } |
      f2 ~ |
      f4 r8 \bar "|."
    }
    {
      f4 \tuplet 3/2 { g8 f c } |
      bf4 \tuplet 3/2 { a8 c bf } |
      a2 ~ |
      a4 r8
    }
  >>
}

nhacPhanSau = \relative c' {
  \key f \major
  \time 2/4
  <<
    {
      \voiceOne
      f4 g8 (a)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      f8 (d) c4
    }
  >>
  \oneVoice
  <<
    {
      d4. bf'8 |
      g c4 e,8 |
      f4 r8 \bar "|."
    }
    {
      bf,4. d8 |
      e e4 c8 |
      a4 r8
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Tình thương Chúa muôn đời con luôn ca tụng,
      Vạn kiếp miệng con sẽ cao rao lòng thành tín của Ngài.
      Vì Chúa phán: Tình thương đó xây dựng đến thiên thu,
      Đức tín thành của Chúa thiết lập trên cung trời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Lập giao ước với người Ta đây tuyền chọn,
      Thề hứa cùng Đa -- vít tôi trung rằng:
      dòng dõi của ngươi bền vững mãi
      vì ta muốn xây dựng đến thiên thu,
      muốn thiết lập củng cố
      \markup { \underline "ngai" } vàng ngươi muôn đời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Phục suy Chúa, thiên đình ca uy công Ngài,
      thần thánh cùng lên tiếng tuyên xưng lòng thành tín của Ngài.
      Một Chúa đó, từ thiên giới ai hòng sánh vai đâu!
      Có thánh thần nào dám
      \markup { \underline "so" } cùng uy phong Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Thật vinh phúc, dân nào tung hô ca ngợi,
      Lạy Chúa, Ngài soi ánh Tôn Nhan để họ tiến đều lên.
      Nhờ biết rõ được Danh Chúa, suốt ngày sẽ hân hoan.
      Bởi \markup { \underline "vì" } Ngài
      \markup { \underline "công" } chính, khiến họ hiên ngang hoài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Nhờ ơn Chúa, dân Ngài quang vinh uy hùng,
      nhờ Chúa làm uy thế chúng con nổi bật khắp mọi nơi,
      Người hướng dẫn đoàn con đó, chính Ngài đã tôn phong.
      Chúa \markup { \underline "đặt" } người của Chúa
      \markup { \underline "lên" } làm vua cai trị.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Hồi xưa Chúa đã từng kinh qua linh thị
      mà phán cùng ai những hiếu trung và thành tín rằng đây:
      một dũng sĩ mà Ta đã cứu độ, và thi ân,
      cất nhắc một hùng sĩ \markup { \underline "Ta" }
      chọn nơi dân này.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Này Đa -- vít, Ta gặp khi Ta đương tìm,
      Đầy tớ mà Ta đã tôn phong bằng việc xức dầu cho.
      Và mãi mãi bàn tay Chúa chẳng ngừng đỡ nâng luôn,
      lấy dũng lực củng cố vững vàng muôn muôn đời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Này Ta sẽ yêu người kiên trung một lòng,
      người sẽ nhờ danh thánh Ta đây mà được dũng mạnh thêm.
      Người sẽ nói cùng Thiên Chúa: Thân phụ của con đây,
      Chúa dũng lực là núi cứu độ thân con này.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Người thưa Chúa: Thân phụ con nay là Ngài,
      là Chúa mà con kính tin luôn, là Núi đã độ trì.
      Và Chúa phán: Phần Ta sẽ tôn làm trưởng nam Ta,
      Sẽ khiến người vượt trổi \markup { \underline "hơn" }
      mọi vua gian trần.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Từ muôn thuở muôn đời Ta yêu thương người,
      và sẽ hằng luôn giữ kiên trung lời kết ước cùng người,
      Dòng dõi đó được Ta hứa giữ gìn đến muôn năm,
      Ngai \markup { \underline "vàng" } người bền vững
      ví tựa muôn cung trời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      Người thưa Chúa: Thân phụ con nay là Ngài,
      là Chúa mà con kính tin luôn, là Núi đá độ trì.
      Và Chúa phán: Này Ta sẽ thương người đến muôn năm,
      Sẽ giữ hoài \markup { \underline "giao" } ước
      với người luôn khôn rời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "12."
      \override Lyrics.LyricText.font-shape = #'italic
      Mà như nếu miêu duệ không tuân lệnh truyền,
      chẳng sống và theo đúng ý như mọi huấn giới của Ta.
      Và nếu chúng làm sai trái những luật pháp Ta ban,
      Chẳng chấp hành thật đúng thánh chỉ Ta ban truyền.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "13."
      Thì Ta lấy roi mà ra tay sửa phạt.
      Vì chúng từng sai lỗi bao phen,
      nên Ta đánh đòn đây.
      Dù thế nữa thì Ta vẫn chẳng đoạn nghĩa yêu thương,
      quyết chẳng hề bội tín với người đây khi nào.
    }
  >>
}

loiPhanHai = \lyricmode {
  Con sẽ ca tụng tình thương của Chúa đến muôn đời.
}

loiPhanBa = \lyricmode {
  Ta đã tìm ra Đa -- vít là nghĩa bộc Ta.
}

loiPhanBon = \lyricmode {
  Ta sẽ yêu thương người và giữ lòng tín trung.
}

loiPhanNam = \lyricmode {
  Ta sẽ yêu thương người bền vững muôn đời.
}

loiPhanSau = \lyricmode {
  Dòng dõi người sẽ vạn kỷ? trường tồn.
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
        \line { \small "-Cn B /4MV: câu 1, 2, 10 + Đ.1" }
        \line { \small "-Ngày 24/12: câu 1, 2, 10 + Đ.1" }
        \line { \small "-Vọng G.Sinh: câu 2, 4, 10 + Đ.1" }
        \line { \small "-t6 c /1TN: câu 4, 5 + Đ.1" }
        \line { \small "-t3 c /2TN: câu 6, 7, 9 + Đ.2" }
        \line { \small "-t2 c /3TN: câu 6, 7, 8 + Đ.3" }
        \line { \small "-t4 c /3TN: câu 2, 9, 11 + Đ.4" }
        \line { \small "-t7 c /11TN: câu 2, 3, 11, 12, 13 + Đ.4" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-Cn A /13TN: câu 1, 2, 4, 10 + Đ.1" }
        \line { \small "-lễ truyền dầu: câu 7, 8 + Đ.1" }
        \line { \small "-t5 /4PS: câu 1, 7, 8 + Đ.1" }
        \line { \small "-T.Mục từ?: câu 1, 2, 7, 8 + Đ.1" }
        \line { \small "-Rửa tội: câu 1, 4, 7, 8 + Đ.1" }
        \line { \small "-Truyền chức: câu 7, 8 + Đ.1" }
        \line { \small "-T.Giuse + câu 1, 2, 10 + Đ.5" }
        \line { \small "-T.Marcô + câu 1, 3, 4 + Đ.1" }
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
