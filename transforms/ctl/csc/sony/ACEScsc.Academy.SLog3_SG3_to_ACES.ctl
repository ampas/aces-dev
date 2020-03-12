
// <ACEStransformID>ACEScsc.SLog3_SG3_to_ACES.a1.v1</ACEStransformID>
// <ACESuserName>SLog3 SG3 to ACES2065-1</ACESuserName>

//
// ACES Color Space Conversion - S-Log3 S-Gamut3 to ACES
//
// converts S-Log3, S-Gamut3 to 
//          ACES2065-1 (AP0 w/ linear encoding)
//



const float SG3_2_AP0_MAT[3][3] = {
  { 0.7529825954,  0.0217076974, -0.0094160528},
  { 0.1433702162,  1.0153188355,  0.0033704179},
  { 0.1036471884, -0.0370265329,  1.0060456349}
};



float SLog3_to_lin( input varying float in)
{
    float out;
    if ( in >= 171.2102946929 / 1023.0 )
    {
        out = pow(10.0, (in * 1023.0 - 420.0) / 261.5) * (0.18 + 0.01) - 0.01;
    }
    else
    {
        out = (in * 1023.0 - 95.0) * 0.01125000 / (171.2102946929 - 95.0);
    }
    return out;
}



void main
(   
    input varying float rIn,
    input varying float gIn,
    input varying float bIn,
    input varying float aIn,
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    output varying float aOut
)
{
    float lin_SG3[3];
    lin_SG3[0] = SLog3_to_lin( rIn);
    lin_SG3[1] = SLog3_to_lin( gIn);
    lin_SG3[2] = SLog3_to_lin( bIn);

    float ACES[3] = mult_f3_f33( lin_SG3, SG3_2_AP0_MAT);
  
    rOut = ACES[0];
    gOut = ACES[1];
    bOut = ACES[2];
    aOut = aIn;
}