
// <ACEStransformID>urn:ampas:aces:transformId:v1.5:IDT.ARRI.Alexa-v2-raw-EI400-CCT5100.a1.v1</ACEStransformID>
// <ACESuserName>ACES 1.0 Input - ARRIRAW (EI400, 5100K)</ACESuserName>

// ARRI ALEXA IDT for ALEXA linear files
//  with camera EI set to 400
//  and CCT of adopted white set to 5100K
// Written by v2_IDT_maker.py v0.05 on Friday 19 December 2014

const float EI = 400.0;
const float black = 256.0 / 65535.0;
const float exp_factor = 0.18 / (0.01 * (400.0/EI));

void main
(	input varying float rIn,
	input varying float gIn,
	input varying float bIn,
	input varying float aIn,
	output varying float rOut,
	output varying float gOut,
	output varying float bOut,
	output varying float aOut)
{

	// convert to white-balanced, black-subtracted linear values
	float r_lin = (rIn - black) * exp_factor;
	float g_lin = (gIn - black) * exp_factor;
	float b_lin = (bIn - black) * exp_factor;

	// convert to ACES primaries using CCT-dependent matrix
	rOut = r_lin * 0.793041 + g_lin * 0.144787 + b_lin * 0.062172;
	gOut = r_lin * 0.072228 + g_lin * 1.078317 + b_lin * -0.150545;
	bOut = r_lin * 0.041417 + g_lin * -0.287641 + b_lin * 1.246224;
	aOut = 1.0;

}
