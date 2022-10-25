% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 50"
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
  \partial 8 d16 d |
  d4. a8 |
  f'8. e16 \tuplet 3/2 { d8 e g } |
  a4. bf16 g |
  a4 \tuplet 3/2 { g8 f a } |
  e4 e16 (f) e8 |
  d4 \tuplet 3/2 { f8 e e } |
  a4 r8 f16 f |
  g4 \tuplet 3/2 { f8 e a } |
  d,2 ~ |
  d4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      a'4 \tuplet 3/2 { a8 a bf } |
      g4. f16 a |
      g8 bf e, f |
      d4 r8 \bar "|."
    }
    {
      f4 \tuplet 3/2 { f8 f g } |
      e4. d16 f |
      e8 d c c |
      c4 r8
    }
  >>
}

nhacPhanBa = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 f16 e |
  <<
    {
      f4 \tuplet 3/2 { g8 f g } |
      g8 a f e |
      d2 ~ |
      d4 r8 \bar "|."
    }
    {
      f4 \tuplet 3/2 { e8 d e } |
      e f d c |
      d2 ~ |
      d4 r8
    }
  >>
}

nhacPhanBon = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 a8 |
  e'4. f16 e |
  d8
  <<
    {
      e f g |
      a2 ~ |
      a4 r8 \bar "|."
    }
    {
      c,8 d e |
      f2 ~ |
      f4 r8
    }
  >>
}

nhacPhanNam = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a8 |
  bf4. bf8 |
  e,8. a16 \tuplet 3/2 { a,8 a c } |
  d2 ~ |
  d4 r8 \bar "|."
}

nhacPhanSau = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      a8 |
      bf4. g8 |
      a8. a16 \tuplet 3/2 { f8 e a } |
      d,2 ~ |
      d4 r8 \bar "|."
    }
    {
      f8 |
      g4. e8 |
      f8. e16 \tuplet 3/2 { d8 c c } |
      d2 ~ |
      d4 r8
    }
  >>
}

nhacPhanBay = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      a'4. f16 g |
      g8. f16 \tuplet 3/2 { e8 g a } |
      d,2 ~ |
      d4 \bar "|."
    }
    {
      f4. d16 e |
      e8. d16 \tuplet 3/2 { c8 e c } |
      d2 ~ |
      d4
    }
  >>
}

nhacPhanTam = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      a'8 g16 f g8 a |
      a, e' f e |
      d2 ~ |
      d4 \bar "|."
    }
    {
      f8 e16 d c8 a |
      a a d c |
      d2 ~ |
      d4
    }
  >>
}

nhacPhanChin = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a8 |
  bf4 \tuplet 3/2 { bf8 bf g } |
  e4 f8 a |
  g4. a,16 f' |
  e4 \tuplet 3/2 { e8 g a } |
  d,2 ~ |
  d4 r8 \bar "|."
}

nhacPhanMuoi = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a8 |
  bf4 \tuplet 3/2 { g8 g a } |
  f e f g |
  a4 \tuplet 3/2 { a,8 a f' } |
  f e c e |
  d2 ~ |
  d4 r8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Xin thương con, lạy Chúa theo lượng từ bi Chúa,
      xóa tội con theo lượng hải hà.
      Rửa con sạch muôn vàn lầm lỗi
      Tội tình con xin Ngài tẩy luyện.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Vâng con nay đà biết bao tội tình vương mắc,
      suốt ngày đêm luôn ở trước mặt,
      Dám sai phạm với một mình Chúa,
      từng tà gian ngay ở trước Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Xin thương con, lạy Đấng công bình khi tuyên án,
      xét xử luôn theo đường chính trực,
      Lúc ra đời con đà lầm lỗi,
      mẹ hoài thai, con đà vướng tội.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Nhưng luôn luôn Ngài thích tâm hồn ai ngay chính,
      đã dạy khôn, con được thấu triệt.
      Tẩy con sạch, xin Ngài rảy nước rửa sạch con,
      con sẽ trắng ngần.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Cho con nghe ngàn tiêgns rao hò ngợp vui sướng,
      dẫu dập xương nay cũng nhảy mừng.
      Ngoảnh đi đừng trông hoài tội lỗi,
      Tẩy bỏ đi muôn vàn lỗi lầm.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Xin quay đi, lạy Chúa, thôi nhìn mọi sai lỗi,
      xóa bỏ đi bao là lỗi lầm.
      Chúa con thờ, tha mạng khỏi chết,
      Này hồn con khen ngợi Chúa hoài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Ban cho con, lạy Chúa, cõi lòng thực trong trắng,
      phú vào con tinh thần vững mạnh,
      Chớ xua từ con khỏi mặt Chúa,
      đừng biệt con khỏi Thần Trí Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Cho con vui được thấy ơn Ngài thương cứu rỗi,
      đỡ vực con theo lòng quảng đại.
      Lối đi Ngài con sẽ dạy dỗ
      để tội nhân trở lại với Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Tha co con khỏi chết, con hằng ngợi ca Chúa,
      Chúa Trời con, ôi nguồn cứu độ.
      Cúi xin Ngài thương mở miệng lưỡi,
      để hồn con dâng lời tán tụng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Cho con vui được thấy ơn Ngài thương cứu rỗi,
      đỡ vực con theo lòng quảng đại.
      Cúi xin Ngài thương mở miệng lưỡi,
      để hồn con dâng lời tán tụng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      Đâu ra chi, lạy Chúa, phẩm vật con dâng tiến,
      lễ toàn thiêu đâu Ngài có cần.
      Lễ dâng Ngài, tâm thần dập nát,
      Ngài chẳng chê cõi lòng nát dập.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "12."
      \override Lyrics.LyricText.font-shape = #'italic
      Con van xin, lạy Chúa thương mở miệng con mãi,
      cất lời lên ca tụng Chúa hoài.
      Lễ dâng Ngài tâm thần dập nát,
      Ngài chẳng chê cõi lòng nát dập.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "13."
      Trên Si -- on, nguyện Chúa thương đổ tràn ân phúc,
      lũy thành xưa, xin Ngài tái tạo,
      Lúc bấy giờ, xin nhận của lễ
      được toàn thiêu theo luật đã truyền.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa xin thương chúng con vì chúng con đã phạm đến Ngài.
}

loiPhanBa = \lyricmode {
  Ôi lạy Chúa, xin tạo cho con trái tim trong sạch.
}

loiPhanBon = \lyricmode {
  Miệng con sẽ loan truyền lời ca khen Chúa.
}

loiPhanNam = \lyricmode {
  Tôi sẽ chỗi dậy trở về cùng cha tôi.
}

loiPhanSau = \lyricmode {
  Ta muốn tình thương chứ chẳng cần lễ vật.
}

loiPhanBay = \lyricmode {
  Lạy Chúa, nguyện thương con theo lòng nhân nghĩa Ngài.
}

loiPhanTam = \lyricmode {
  Lạy Chúa, xin đừng chê cõi lòng tan nát khiêm cung.
}

loiPhanChin = \lyricmode {
  Ta sẽ lấy nước tinh tuyền rảy các ngươi,
  và các ngươi sạch bao vết tội.
}

loiPhanMuoi = \lyricmode {
  Ta sẽ ban cho các ngươi một quả tim mới,
  đặt thần trí mới trong lòng các ngươi.
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
        \line { \small "-Lễ Tro: câu 1, 2, 7, 10 + Đ.6" }
        \line { \small "-t6 sau lễ Tro: câu 1, 2, 3, 5, 11 + Đ.7" }
        \line { \small "-Cn A /1MC: câu 1, 2, 7, 10 + Đ.6" }
        \line { \small "-t4 /1MC: câu 1, 7, 11 + Đ.7" }
        \line { \small "-t7 /3MC: câu 1, 11, 13 + Đ.5" }
        \line { \small "-Cn B /5MC: câu 1, 7, 8 + Đ.2" }
        \line { \small "-Vọng PS (b.7): câu 7, 8, 11 + Đ.2" }
        \line { \small "-t6 c /3TN: câu 1, 2, 3, 5 + Đ.1" }
        \line { \small "-t7 c /3TN: câu 7, 8, 9 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-t3 c /11TN; câu 1, 2, 6 + Đ.6" }
        \line { \small "-t6 c /14TN: câu 1, 4, 7, 10 + Đ.3" }
        \line { \small "-t3 c /18TN: câu 1, 2, 3, 7 + Đ.6" }
        \line { \small "-t5 c /18TN: câu 7, 8, 11 + Đ.2" }
        \line { \small "-t7 c /19TN: câu 7, 8, 11 + Đ.2" }
        \line { \small "-t5 c /20TN: câu 7, 8, 11 + Đ.8" }
        \line { \small "-Cn C /24TN: câu 1, 7, 12 + Đ.4" }
        \line { \small "-Rửa tội: câu 1, 4, 7, 10 + Đ.2 hoặc Đ.9" }
        \line { \small "-Cầu ơn tha tội: câu 1, 2, 7, 10 + Đ.1" }
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
      instrumentName = \markup { \bold "Đ.8" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanChin
        }
      \new Lyrics \lyricsto beSop \loiPhanChin
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
      instrumentName = \markup { \bold "Đ.9" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanMuoi
        }
      \new Lyrics \lyricsto beSop \loiPhanMuoi
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
