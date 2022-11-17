TEST_START  =$1000        ;start address of test driver
TEST_INPUT  =$8000        ;input vector
TEST_OUTPUT =$9000        ;output vector
TEST_OUTPUT_END =$9006
*       = TEST_START
test_start
            nop
            nop 
            nop
                
            jsr test_case

            nop
            nop 
test_end    nop

-           jmp - 

test_case 
            ldx #6
-           lda test_input-1,x
            sta test_output-1,x
            dex 
            bne -

            rts

 ;data
*=TEST_INPUT
test_input
*=TEST_OUTPUT
test_output
*=TEST_OUTPUT_END
test_output_end