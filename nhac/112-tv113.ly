% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 103"
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
  \key g \major
  \time 2/4
  \partial 8 d16 g |
  b4 \tuplet 3/2 { b8 g b } |
  a4 r8 g16 b |
  c4 \tuplet 3/2 { c8 b a } |
  e'8. b16 \tuplet 3/2 { d8 c b } |
  a4 r8 b16 e, |
  e8. e16 \tuplet 3/2 { g8 g a } |
  d,4 \tuplet 3/2 { c8 b d } |
  a'8. fs16 \tuplet 3/2 { e8 fs d } |
  g2 ~ |
  g4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key g \major
  \time 2/4
  \partial 8 d16 g |
  <<
    {
      b8. c16 \tuplet 3/2 { c8 a d }
    }
    {
      g,8. a16 \tuplet 3/2 { a8 g fs }
    }
  >>
  g2 ~ |
  g4 r8 \bar "|."
}

nhacPhanBa = \relative c' {
  \key g \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      b'4. g16 a |
      a8. a16 \tuplet 3/2 { a8 c d } |
      g,2 ~ |
      g4 r8
    }
    {
      g4. e16 c |
      d8. d16 \tuplet 3/2 { d8 e fs } |
      b,2 ~ |
      b4 r8
    }
  >>
  \bar "|."
}

nhacPhanBon = \relative c' {
  \key g \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      b'4. c16 b |
      a4 \tuplet 3/2 { a8 d fs, }
    }
    {
      g4. a16 g |
      fs4 \tuplet 3/2 { fs8 e d }
    }
  >>
  g2 ~ |
  g4 r8 \bar "|."
}

nhacPhanNam = \relative c'' {
  \key g \major
  \time 2/4
  \partial 8 g8 |
  g4 \tuplet 3/2 { a8 d, <b' g> } |
  <<
    {
      b4 \tuplet 3/2 { g8 g g } |
      c4. a16 d
    }
    {
      g,4 \tuplet 3/2 { e8 e e } |
      a4. fs16 fs
    }
  >>
  g4 r8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Hồn tôi hỡi, chúc tụng Chúa đi,
      lạy Thiên Chúa, Đấng con thờ kính,
      Ngài quá ư vĩ đại.
      Áo Ngài mặc toàn oai phong lẫm liệt,
      cẩm bào Ngài khoác muôn vạn ánh hào quang.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Hồn tôi hỡi, chúc tụng Chúa đi, lạy Thiên Chúa,
      Đấng con thờ kính, Ngài quá ư vĩ đại.
      Quá nhiều việc đều do tay Chúa làm,
      địa cầu đầy dẫy những vật Chúa tạo ra.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Nền kiên vững của mặt đất đây là do Chúa đích thân củng cố,
      ngàn kiếp khôn chuyển rời.
      Khắp địa cầu, vực sâu như áo choàng,
      quy tụ nguồn nước trên đỉnh núi đồi cao.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Từng con suối Chúa làm phát sinh,
      từ khe thác giữa nơi đồi núi lượn khúc quanh co hoài,
      chim làm tổ ở ngay bên suối này,
      giữa lùm cây lá líu lo hót rền vang.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Đàn gia súc sống nhờ cỏ xanh,
      còn nhân thế Chúa cho họ có mọi thứ ra để dùng.
      \markup { \italic "(trở" } 
      \markup { \italic "lại" }
      \markup { \italic "@)" }
      \repeat unfold 12 { _ }
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "@"
      Từ ruộng đất kiếm được bánh ăn,
      và pha chế những ly rượu quý làm phấn khởi tâm thần.
      Xức mặt mày đẹp xinh trơn loáng dầu,
      bởi nhờ cơm bánh no lòng chắc dạ luôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Kỳ công Chúa, quá nhiều, Chúa ơi,
      thật phong phú với muôn mầu sắc đầy ắp dương gian này.
      Với vạn vật Ngài khôn ngoan tác thành.
      Linh hồn tôi hỡi, ca tụng Chúa Trời đi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Kìa muông thú ngước nhìn Chúa luôn,
      đợi trông Chúa dủ thương nhìn đến dọn bữa cho no lòng.
      Chúng vội vàng lượm ngay khi Chúa tặng,
      thỏa lòng vì những ân lộc Chúa rộng ban.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Vừa khi Chúa rút lại khí thiêng,
      là thân chúng trở lui bụi cát vì tắt hơi thở rồi.
      Muốn tạo lại, Ngài ban sinh khí vào.
      Bởi Ngài đổi mới bộ mặt của trần gian.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Làn sinh khí Chúa vừa phú ban,
      là thân chúng đã được tạo tác.
      Ngài biến đổi địa cầu.
      Đến ngàn đời, Ngài vinh quang chói lọi.
      Sự nghiệp của Chúa luôn làm Chúa hỉ hoan.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Nguyện muôn kiếp Chúa hằng hiển vinh,
      và mong ước những công trình Chúa làm Chúa mãi vui mừng.
      Tiếng lòng này cầu mong vui ý Ngài.
      Bời Ngài là chính hoan lạc của đời tôi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      Ngợi khen Chúa suốt đời của tôi,
      còn sinh khí sẽ luôn còn hát mừng Chúa tôi tôn thờ.
      Tiếng lòng này cầu mong vui ý Ngài.
      Bời Ngài là chính hoan lạc của đời tôi.
    }
  >>
}

loiPhanHai = \lyricmode {
  Hồn tôi hỡi, hãy chúc tụng Chúa Trời.
}

loiPhanBa = \lyricmode {
  Nguyện Chúa được hân hoan vì kỳ công Chúa làm.
}

loiPhanBon = \lyricmode {
  Lạy Chúa, đất chứa chan ân lộc của Ngài.

}

loiPhanNam = \lyricmode {
  Xin sai Thánh Thần Chúa đến để Ngài đổi mới mặt đất này.
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
        \line { \small "-t2 l /5TN: câu 1, 3, 4, 6 + Đ.2" }
        \line { \small "-t4 l /5TN: câu 1, 7, 8 + Đ.1" }
        \line { \small "-vọng Hiện Xuống: câu 1, 6, 7, 8 + Đ.4" }
        \line { \small "-lễ Hiện Xuống: câu 2, 8, 10 + Đ.4" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-Thêm sức: câu 2, 7, 9, 10 + Đ.4" }
        \line { \small "-C.T.Thần (NL): câu 1, 6, 7, 8 + Đ.4" }
        \line { \small "-khi cày cấy: câu 1, 5, 6, 7 + Đ.3" }
        \line { \small "-Chúa chịu P.Rửa C: câu 1, 6, 7, 8 + Đ.1" }
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
