% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 21"
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
  f8 (e) d a |
  a'4. a8 |
  d d b! (a) |
  fs8. g16 b!8 a |
  a4 r8 g16 f! |
  g8 a g f |
  e4 f8 e |
  d4. c16 c |
  d8 g4 f16 (g) |
  a4 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key f \major
  \time 2/4
  \partial 4 a8 a |
  bf (a) g g |
  a4. f8 |
  e a a,4 |
  d2 \bar "|."
}

nhacPhanBa = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 d4 |
  a' g8 f |
  bf4. a16 (g) |
  f8 (g) f (e) |
  d2 \bar "||"
}

nhacPhanBon = \relative c'' {
  \key f \major
  \time 2/4
  \partial 4 a4 |
  bf g8 bf |
  d4. d8 |
  a g f (g) |
  a4 f8 (e) |
  d2 \bar "|."
}

nhacPhanNam = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 d4 |
  a' g8 (a) |
  bf4. a8 |
  a d d (e16 d) |
  cs4. d8 |
  a g f e |
  d2 \bar "|."
}

nhacPhanSau = \relative c'' {
  \key f \major
  \time 2/4
  \partial 4 a8 e |
  e4. e8 |
  g a a,4 |
  d2 ~ |
  d4 r \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Bao người nhiếc mắng, vừa thấy bóng con là họ đã chê bai:
      Tên này luôn kính tin Chúa Trời,
      nếu thương tình hẳn là Ngài lo giải thoát.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Ác thù xấn tới, tựa lũ chó vây chặt,
      đâm thủng chân tay, xương xẩu con đếm xem vắn dài,
      mắt căm hờn nhìn chòng chọc con nhạo báng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Chía phần áo khoác, còn chiếc áo trong họ cũng bắt thăm luôn.
      Ôi lạy Thiên Chúa con nương nhờ, cứu con cùng,
      Ngài đừng lìa xa, bỏ thí.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Con nguyện mãi mãi truyền bá thánh danh Ngài cho khắp anh em.
      Xin được lên tiếng nơi công hội,
      tiến dâng Ngài một bài ngợi ca mừng kính.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Ai sợ kính Chúa, nào cất tiếng lên mà cung chúc tôn vinh.
      Miêu duệ Gia -- cop mau ca mừng,
      Ích -- diên nào thần phục quyền uy của Chúa.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Hưởng lộc phúc Chúa, nguyện sẽ tán dương ngay công nhóm con dân.
      Xin thực thi những chi đoan nguyền
      ở trước mặt cộng đoàn người tôn sợ Chúa.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Kẻ hèn tứng thiếu được mãi thỏa thuê vì ăn uống no nê,
      ai tìm Nhan Chúa sẽ ca mừng,
      Chúa cho họ được ngàn đời vui hạnh phúc.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Khắp cùng thế giới cùng nhắc nhớ trở về bên Chúa đi thôi.
      Bao là dân nước trên gian trần
      hãy phủ phục thờ lạy thần nhan của Chúa.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Sẽ phục bái Chúa là hết những ai đà an giấc thiên thu
      sẽ phục suy trước tôn nhan Ngài
      hết những người đà trở về nơi bụi đất.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Thiên hạ sẽ nói về Chúa mãi cho đoàn con cháu mai sau.
      Cho hậu sinh biết Chúa công bình,
      chính tay Ngài đà thực hiện bao việc đó.
    }
  >>
}

loiPhanHai = \lyricmode {
  Ôi Thiên Chúa, ôi Thiên Chúa sao Ngài nỡ bỏ con.
}

loiPhanBa = \lyricmode {
  Lạy Chúa, ai tìm Chúa sẽ ngợi khen Ngài.
}

loiPhanBon = \lyricmode {
  Khi Đấng Phù trợ đến các con sẽ làm chứng cho Thầy.
}

loiPhanNam = \lyricmode {
  Lạy Chúa vì Chúa mà lời con ca ngợi đã vang lên trong công hội.
}

loiPhanSau = \lyricmode {
  Kẻ nghèo hèn được ăn uống thỏa thuê.
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
        \line { \small "-t3 l /4TN: câu 6, 7, 8, 9, 10 + Đ.2" }
        \line { \small "-t3 c /31TN: câu 6, 7, 8, 9, 10 + Đ.2" }
        \line { \small "-Cn B /5PS: câu 6, 7, 8, 9, 10 + Đ.4" }
        \line { \small "-Lễ Lá: câu 1, 2, 3, 4, 5 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { " " }
        \line { \small "-ban Bt. Thêm sức: câu 4, 5, 6, 7, 8, 10 + Đ.3" }
        \line { \small "          (hát 2 câu một rồi mới Đáp)" }
        \line { \small "-cầu khi nghèo đói: câu 4, 5, 6, 7, 8, 10 + Đ.5" }
        \line { \small "-suy tôn Thánh giá: câu 1, 2, 3, 4, 5 + Đ.1" }
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
    \override Lyrics.LyricSpace.minimum-distance = #0.5
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

